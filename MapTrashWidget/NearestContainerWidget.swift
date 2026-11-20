//
//  NearestContainerWidget.swift
//  MapTrashWidget
//
//  Widget « conteneur le plus proche » (écran d'accueil + écran verrouillé).
//

import WidgetKit
import SwiftUI
import AppIntents
import CoreLocation

// MARK: - Configuration

struct SelectWasteTypeIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Type de conteneur"
    static let description = IntentDescription("Choisissez le type de conteneur à afficher.")

    @Parameter(title: "Type", default: .glass)
    var type: WasteType

    init() {}
    init(type: WasteType) { self.type = type }
}

// MARK: - Données

struct NearestEntry: TimelineEntry {
    enum State {
        case found(Container, CLLocationDistance)
        case noLocation
    }

    let date: Date
    let type: WasteType
    let state: State
}

/// Les conteneurs sont chargés une seule fois par processus d'extension.
private enum WidgetData {
    static let containers: [Container] = ContainerRepository.loadBundled()
}

/// Récupère une position récente (une seule mise à jour, avec délai maximal).
private enum WidgetLocation {
    static func current() async -> CLLocation? {
        let manager = CLLocationManager()
        if let cached = manager.location, cached.timestamp.timeIntervalSinceNow > -600 {
            return cached
        }
        guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else {
            return manager.location
        }
        return await withTaskGroup(of: CLLocation?.self) { group in
            group.addTask {
                do {
                    for try await update in CLLocationUpdate.liveUpdates() {
                        if let location = update.location { return location }
                    }
                } catch {}
                return nil
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(8))
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first ?? manager.location
        }
    }
}

struct NearestProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> NearestEntry {
        NearestEntry(date: .now, type: .glass, state: .found(.sample, 190))
    }

    func snapshot(for configuration: SelectWasteTypeIntent, in context: Context) async -> NearestEntry {
        if context.isPreview {
            return NearestEntry(date: .now, type: configuration.type, state: .found(.sample(configuration.type), 190))
        }
        return await entry(for: configuration.type)
    }

    func timeline(for configuration: SelectWasteTypeIntent, in context: Context) async -> Timeline<NearestEntry> {
        let entry = await entry(for: configuration.type)
        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(15 * 60)))
    }

    private func entry(for type: WasteType) async -> NearestEntry {
        guard let location = await WidgetLocation.current(),
              let container = ContainerRepository.nearest(type, in: WidgetData.containers, from: location)
        else {
            return NearestEntry(date: .now, type: type, state: .noLocation)
        }
        return NearestEntry(date: .now, type: type, state: .found(container, container.location.distance(from: location)))
    }
}

// MARK: - Vues

struct NearestWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NearestEntry

    var body: some View {
        content
            .widgetURL(URL(string: "maptrash://nearest?type=\(entry.type.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"))
            .containerBackground(for: .widget) {
                LinearGradient(colors: [entry.type.color.opacity(0.22), entry.type.color.opacity(0.06)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular: circular
        case .accessoryRectangular: rectangular
        case .accessoryInline: inline
        case .systemMedium: medium
        default: small
        }
    }

    private var badge: some View {
        Image(systemName: entry.type.icon)
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(entry.type.color.gradient, in: Circle())
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                badge
                Spacer()
                Image(systemName: "location.fill").font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text(entry.type.fullName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            switch entry.state {
            case .found(let container, let distance):
                Text(DistanceFormatter.distance(distance))
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .minimumScaleFactor(0.7)
                Text(container.displayAddress)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            case .noLocation:
                Text("Ouvrez l'app pour activer la localisation")
                    .font(.caption)
                    .lineLimit(3)
            }
        }
    }

    private var medium: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                badge
                Spacer(minLength: 0)
                Text("\(entry.type.fullName) le plus proche")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                if case .found(_, let distance) = entry.state {
                    Text(DistanceFormatter.distance(distance))
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .minimumScaleFactor(0.6)
                }
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 8) {
                switch entry.state {
                case .found(let container, let distance):
                    Label(container.displayAddress, systemImage: "mappin.and.ellipse")
                        .font(.subheadline.weight(.medium))
                        .lineLimit(3)
                    Label("≈ \(DistanceFormatter.walkingTime(distance)) à pied", systemImage: "figure.walk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label(container.commune, systemImage: "building.2")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                case .noLocation:
                    Text("Ouvrez Tri Nice et autorisez la localisation pour voir le conteneur le plus proche.")
                        .font(.subheadline)
                }
                Spacer(minLength: 0)
                Text("Toucher pour l'itinéraire")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(entry.type.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: entry.type.icon).font(.system(size: 14, weight: .semibold))
                if case .found(_, let distance) = entry.state {
                    Text(DistanceFormatter.distance(distance))
                        .font(.system(size: 11, weight: .semibold))
                        .minimumScaleFactor(0.6)
                }
            }
        }
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label(entry.type.fullName, systemImage: entry.type.icon)
                .font(.headline)
            switch entry.state {
            case .found(let container, let distance):
                Text("\(DistanceFormatter.distance(distance)) · \(DistanceFormatter.walkingTime(distance))")
                    .font(.subheadline)
                Text(container.displayAddress)
                    .font(.caption)
                    .lineLimit(1)
            case .noLocation:
                Text("Localisation requise").font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inline: some View {
        switch entry.state {
        case .found(_, let distance):
            Label("\(entry.type.name) à \(DistanceFormatter.distance(distance))", systemImage: entry.type.icon)
        case .noLocation:
            Label(entry.type.name, systemImage: entry.type.icon)
        }
    }
}

// MARK: - Widget

struct NearestContainerWidget: Widget {
    let kind = "NearestContainerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectWasteTypeIntent.self, provider: NearestProvider()) { entry in
            NearestWidgetView(entry: entry)
        }
        .configurationDisplayName("Conteneur le plus proche")
        .description("Distance et adresse du conteneur le plus proche du type choisi.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct MapTrashWidgetBundle: WidgetBundle {
    var body: some Widget {
        NearestContainerWidget()
    }
}

// MARK: - Exemple

extension Container {
    static let sample = sample(.glass)

    static func sample(_ type: WasteType) -> Container {
        Container(id: "sample", type: type, latitude: 43.6985, longitude: 7.27,
                  address: "RUE GUSTAVE DELOYE FACE AU N°11", commune: "Nice", kind: "AERIEN", collectionDay: nil)
    }
}

#Preview(as: .systemSmall) {
    NearestContainerWidget()
} timeline: {
    NearestEntry(date: .now, type: .glass, state: .found(.sample, 190))
    NearestEntry(date: .now, type: .textile, state: .noLocation)
}
