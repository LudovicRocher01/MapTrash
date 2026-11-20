//
//  HomePanel.swift
//  MapTrash
//
//  Contenu par défaut de la feuille : filtres, le plus proche, favoris, autour de moi.
//

import SwiftUI
import CoreLocation

struct HomePanel: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            FilterChips()

            if let here = location.location {
                nearestSection(from: here)
                favoritesSection(from: here)
                nearbySection(from: here)
            } else {
                LocationPrompt()
                favoritesSection(from: nil)
            }
        }
    }

    // MARK: Le plus proche

    @ViewBuilder
    private func nearestSection(from here: CLLocation) -> some View {
        let types = WasteType.allCases.filter { app.enabledTypes.contains($0) }
        if !types.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Le plus proche", icon: "scope")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(types) { type in
                            if let match = app.nearest(type, from: here) {
                                NearestCard(type: type, distance: match.distance) {
                                    app.select(.container(match.container))
                                }
                            }
                        }
                    }
                }
                .scrollClipDisabled()
            }
        }
    }

    // MARK: Favoris

    @ViewBuilder
    private func favoritesSection(from here: CLLocation?) -> some View {
        let favorites = app.favoriteContainers(from: here)
        if !favorites.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Mes favoris", icon: "star.fill")
                VStack(spacing: 0) {
                    ForEach(Array(favorites.enumerated()), id: \.element.container.id) { index, item in
                        if index > 0 { Divider().padding(.leading, 62) }
                        ContainerRow(container: item.container, distance: item.distance, isFavorite: true) {
                            app.select(.container(item.container))
                        }
                    }
                }
                .tileBackground()
            }
        }
    }

    // MARK: Autour de moi

    @ViewBuilder
    private func nearbySection(from here: CLLocation) -> some View {
        let nearby = app.nearby(from: here, limit: 15)
        if !nearby.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionTitle("Autour de moi", icon: "figure.walk")
                LazyVStack(spacing: 0) {
                    ForEach(Array(nearby.enumerated()), id: \.element.container.id) { index, item in
                        if index > 0 { Divider().padding(.leading, 62) }
                        ContainerRow(container: item.container, distance: item.distance,
                                     isFavorite: app.favorites.contains(item.container)) {
                            app.select(.container(item.container))
                        }
                    }
                }
                .tileBackground()
            }
        }
    }
}

// MARK: - Composants

struct SectionTitle: View {
    let title: String
    let icon: String

    init(_ title: String, icon: String) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
            .accessibilityAddTraits(.isHeader)
    }
}

struct FilterChips: View {
    @Environment(AppState.self) private var app

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WasteType.allCases) { type in
                    chip(title: type.name, icon: type.icon, color: type.color, isOn: app.enabledTypes.contains(type)) {
                        app.toggle(type)
                    }
                }
                chip(title: "Déchetteries", icon: "building.2.fill", color: .brown, isOn: app.showCenters) {
                    app.showCenters.toggle()
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
        .sensoryFeedback(.selection, trigger: app.enabledTypes)
    }

    private func chip(title: String, icon: String, color: Color, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) { action() }
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 12)
                .frame(minHeight: 36)
                .foregroundStyle(isOn ? .white : color)
                .background(isOn ? AnyShapeStyle(color.gradient) : AnyShapeStyle(Color(.tertiarySystemFill)), in: Capsule())
                .overlay(Capsule().strokeBorder(color.opacity(isOn ? 0 : 0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "affiché" : "masqué")
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

struct NearestCard: View {
    let type: WasteType
    let distance: CLLocationDistance
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                IconBadge(icon: type.icon, color: type.color, size: 36)
                Text(type.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(DistanceFormatter.distance(distance))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    Label(DistanceFormatter.walkingTime(distance), systemImage: "figure.walk")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 112, alignment: .leading)
            .padding(12)
            .tileBackground()
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(type.fullName) le plus proche, à \(DistanceFormatter.distance(distance)), environ \(DistanceFormatter.walkingTime(distance)) à pied")
        .accessibilityAddTraits(.isButton)
    }
}

struct ContainerRow: View {
    let container: Container
    let distance: CLLocationDistance?
    var isFavorite = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(icon: container.type.icon, color: container.type.color, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(container.type.fullName)
                            .font(.subheadline.weight(.semibold))
                        if isFavorite {
                            Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                        }
                    }
                    Text(container.displayAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                if let distance {
                    Text(DistanceFormatter.distance(distance))
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct LocationPrompt: View {
    @Environment(LocationManager.self) private var location

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(icon: "location.fill", color: .blue, size: 36)
            VStack(alignment: .leading, spacing: 8) {
                Text(location.isDenied ? "Localisation désactivée" : "Trouvez le conteneur le plus proche")
                    .font(.subheadline.weight(.semibold))
                Text(location.isDenied
                     ? "Autorisez l'accès à votre position dans les Réglages pour voir les conteneurs autour de vous."
                     : "Votre position reste sur votre téléphone et sert uniquement à calculer les distances.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(location.isDenied ? "Ouvrir les Réglages" : "Activer la localisation") {
                    if location.isDenied { location.openSettings() } else { location.start() }
                }
                .font(.subheadline.weight(.semibold))
                .prominentButtonStyle(tint: .blue)
                .controlSize(.small)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .tileBackground()
    }
}
