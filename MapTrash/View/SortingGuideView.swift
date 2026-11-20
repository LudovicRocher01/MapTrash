//
//  SortingGuideView.swift
//  MapTrash
//
//  Guide du tri : accueil illustré + fiches pilotées par les données.
//

import SwiftUI

private enum GuidePage: Hashable {
    case entry(GuideEntry)
    case centers
}

struct SortingGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    @State private var path: [GuidePage]

    init(initial: GuideRoute) {
        switch initial {
        case .home: _path = State(initialValue: [])
        case .entry(let entry): _path = State(initialValue: [.entry(entry)])
        }
    }

    var body: some View {
        NavigationStack(path: $path) {
            GuideHomeView()
                .navigationTitle("Guide du tri")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("OK") { dismiss() }
                    }
                }
                .navigationDestination(for: GuidePage.self) { page in
                    switch page {
                    case .entry(let entry):
                        GuideDetailView(entry: entry) { type in
                            app.selectNearest(type, from: location.location)
                            dismiss()
                        }
                    case .centers:
                        RecyclingCentersListView(onSelect: { dismiss() })
                    }
                }
        }
    }
}

// MARK: - Accueil

private struct GuideHomeView: View {
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    private let typeEntries = SortingGuide.entries.filter { $0.wasteType != nil }
    @State private var fact = GuideFacts.all.randomElement() ?? ""

    private var gridEntries: [GuideEntry] {
        typeEntries.count.isMultiple(of: 2) ? typeEntries : Array(typeEntries.dropLast())
    }

    private var wideEntry: GuideEntry? {
        typeEntries.count.isMultiple(of: 2) ? nil : typeEntries.last
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Text("Les bons gestes pour chaque déchet, et où les déposer dans la Métropole.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    GuideSectionHeader("Par conteneur")
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(gridEntries) { entry in
                            NavigationLink(value: GuidePage.entry(entry)) {
                                GuideTypeTile(entry: entry)
                            }
                            .buttonStyle(PressableStyle())
                        }
                    }
                    // Nombre impair : la dernière tuile prend toute la largeur.
                    if let last = wideEntry {
                        NavigationLink(value: GuidePage.entry(last)) {
                            GuideTypeTile(entry: last, wide: true)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    GuideSectionHeader("Aller plus loin")
                    VStack(spacing: 0) {
                        NavigationLink(value: GuidePage.entry(SortingGuide.bestPractices)) {
                            GuideWideRow(icon: "leaf.fill", color: .teal,
                                         title: "Bonnes pratiques",
                                         subtitle: "Réduire, réutiliser, composter")
                        }
                        Divider().padding(.leading, 68)
                        NavigationLink(value: GuidePage.centers) {
                            GuideWideRow(icon: "building.2.fill", color: .brown,
                                         title: "Déchetteries",
                                         subtitle: "Encombrants, déchets verts, produits dangereux…")
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .buttonStyle(.plain)
                }

                factCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var factCard: some View {
        Button {
            withAnimation(.snappy) {
                fact = GuideFacts.all.filter { $0 != fact }.randomElement() ?? fact
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "lightbulb.max.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                    .symbolEffect(.bounce, value: fact)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Le saviez-vous ?")
                        .font(.headline)
                    Text(fact)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(fact)
                        .transition(.opacity)
                    Label("Toucher pour une autre astuce", systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(
                LinearGradient(colors: [Color.yellow.opacity(0.18), Color.orange.opacity(0.08)],
                               startPoint: .topLeading, endPoint: .bottomTrailing),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct GuideSectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.title3.weight(.bold))
            .accessibilityAddTraits(.isHeader)
    }
}

private struct GuideTypeTile: View {
    let entry: GuideEntry
    var wide = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(systemName: entry.icon)
                .font(.system(size: 78, weight: .bold))
                .foregroundStyle(.white.opacity(0.18))
                .rotationEffect(.degrees(-12))
                .offset(x: 14, y: 16)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: entry.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(.white.opacity(0.25), in: Circle())
                Spacer(minLength: 10)
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(entry.examples)
                    .font(.caption)
                    .opacity(0.9)
                    .lineLimit(wide ? 1 : 2, reservesSpace: !wide)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
        .frame(height: wide ? 120 : 146)
        .background(GuideGradient(color: entry.color))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: entry.color.opacity(0.3), radius: 8, y: 4)
    }
}

/// Dégradé de la couleur vers une teinte plus sombre (compatible iOS 17).
private struct GuideGradient: View {
    let color: Color

    var body: some View {
        ZStack {
            color
            LinearGradient(colors: [.white.opacity(0.08), .black.opacity(0.22)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

private struct GuideWideRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(icon: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

/// Léger effet d'enfoncement au toucher.
private struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Fiche

struct GuideDetailView: View {
    let entry: GuideEntry
    var onFindNearest: ((WasteType) -> Void)? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero

                if let type = entry.wasteType, let onFindNearest {
                    Button {
                        onFindNearest(type)
                    } label: {
                        Label("Trouver le conteneur le plus proche", systemImage: "location.fill")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .prominentButtonStyle(tint: entry.color)
                }

                ForEach(entry.sections, id: \.title) { section in
                    GuideSectionCard(section: section, accent: entry.color)
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(entry.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: entry.icon)
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(.white.opacity(0.15))
                .rotationEffect(.degrees(-12))
                .offset(x: 24, y: -10)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: entry.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.25), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.largeTitle.weight(.bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(entry.subtitle)
                        .font(.subheadline)
                        .opacity(0.9)
                }

                if !entry.stats.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        ForEach(entry.stats, id: \.value) { stat in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stat.value)
                                    .font(.title3.weight(.heavy))
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(1)
                                Text(stat.label)
                                    .font(.caption2.weight(.medium))
                                    .opacity(0.9)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(10)
                            .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .background(GuideGradient(color: entry.color))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct GuideSectionCard: View {
    let section: GuideSection
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: headerIcon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(section.tint.gradient, in: Circle())
                Text(section.title)
                    .font(.headline)
                Spacer()
                if !section.items.isEmpty, section.style == .accepted || section.style == .rejected {
                    Text("\(section.items.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(section.tint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(section.tint.opacity(0.12), in: Capsule())
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)

            if !section.items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.element.text) { index, item in
                        if index > 0 { Divider().padding(.leading, 48) }
                        row(item, index: index)
                    }
                }
            }

            if let body = section.body {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(.primary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            if section.style == .info {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(accent.opacity(0.25), lineWidth: 1)
            }
        }
    }

    private var headerIcon: String {
        switch section.style {
        case .accepted: "checkmark"
        case .rejected: "xmark"
        case .tips: "lightbulb.fill"
        case .info: "globe.europe.africa.fill"
        }
    }

    private var background: AnyShapeStyle {
        section.style == .info
            ? AnyShapeStyle(accent.opacity(0.1))
            : AnyShapeStyle(Color(.secondarySystemGroupedBackground))
    }

    private func row(_ item: GuideItem, index: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Group {
                if section.style == .tips {
                    Text("\(index + 1)")
                        .font(.subheadline.weight(.bold))
                } else {
                    Image(systemName: item.icon)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .foregroundStyle(section.tint)
            .frame(width: 36, height: 36)
            .background(section.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .accessibilityHidden(true)

            Text(item.text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Déchetteries

struct RecyclingCentersListView: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    let onSelect: () -> Void

    private var sorted: [RecyclingCenter] {
        guard let here = location.location else { return app.centers.sorted { $0.name < $1.name } }
        return app.centers.sorted { $0.clLocation.distance(from: here) < $1.clLocation.distance(from: here) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.brown)
                    Text("Encombrants, déchets verts, gravats, appareils électriques, peintures, huiles… Horaires indicatifs, hors jours fériés.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.brown.opacity(0.1), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(spacing: 0) {
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, center in
                        if index > 0 { Divider().padding(.leading, 66) }
                        Button {
                            app.select(.center(center))
                            onSelect()
                        } label: {
                            HStack(spacing: 12) {
                                IconBadge(icon: "building.2.fill", color: .brown, size: 40)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(center.shortName)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    OpenStateBadge(state: center.openState(), compact: true)
                                }
                                Spacer(minLength: 8)
                                if let here = location.location {
                                    Text(DistanceFormatter.distance(center.clLocation.distance(from: here)))
                                        .font(.subheadline.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Déchetteries")
    }
}
