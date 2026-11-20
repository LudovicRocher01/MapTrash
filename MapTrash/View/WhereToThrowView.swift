//
//  WhereToThrowView.swift
//  MapTrash
//
//  Recherche hors-ligne « Où jeter… ? ».
//

import SwiftUI

struct WhereToThrowView: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    @Binding var query: String
    let onDone: () -> Void
    let onOpenGuide: () -> Void

    private var results: [SortingItem] { SortingDictionary.search(query) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if query.trimmingCharacters(in: .whitespaces).isEmpty {
                suggestions
            } else if results.isEmpty {
                emptyState
            } else {
                ForEach(results.prefix(12)) { item in
                    ResultCard(item: item, action: { act(on: $0) })
                }
            }
        }
    }

    private var suggestions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Recherches fréquentes", icon: "sparkle.magnifyingglass")
            FlexibleChips(items: SortingDictionary.popular) { term in
                query = term
            }
            Text("Tapez le nom d'un objet pour savoir dans quel bac le déposer, ou s'il faut l'apporter en déchetterie, en magasin ou en pharmacie.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "questionmark.bubble")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Aucun résultat pour « \(query) »")
                .font(.headline)
            Text("En cas de doute, déposez-le dans les ordures ménagères plutôt que de perturber le tri, ou consultez le guide.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Ouvrir le guide du tri", action: onOpenGuide)
                .secondaryButtonStyle()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func act(on destination: Destination) {
        switch destination {
        case .container(let type):
            onDone()
            app.selectNearest(type, from: location.location)
        case .recyclingCenter:
            onDone()
            if let center = app.nearestCenter(from: location.location) {
                app.select(.center(center), zoom: true)
            }
        default:
            break
        }
    }
}

private struct ResultCard: View {
    let item: SortingItem
    let action: (Destination) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                IconBadge(icon: item.destination.icon, color: item.destination.color, size: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.destination.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(item.destination.color)
                }
                Spacer(minLength: 0)
            }

            Text(item.advice)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                actionButton(for: item.destination, prominent: true)
                if let alt = item.alternative {
                    actionButton(for: alt, prominent: false)
                }
            }
        }
        .padding(14)
        .tileBackground()
    }

    @ViewBuilder
    private func actionButton(for destination: Destination, prominent: Bool) -> some View {
        let label: String? = switch destination {
        case .container(let type): "\(type.name) le plus proche"
        case .recyclingCenter: "Déchetterie la plus proche"
        default: nil
        }
        if let label {
            let button = Button {
                action(destination)
            } label: {
                Label(label, systemImage: "location.fill")
                    .font(.footnote.weight(.semibold))
            }
            .controlSize(.small)
            if prominent {
                button.prominentButtonStyle(tint: destination.color)
            } else {
                button.secondaryButtonStyle()
            }
        }
    }
}

/// Puces qui passent à la ligne.
struct FlexibleChips: View {
    let items: [String]
    let onTap: (String) -> Void

    var body: some View {
        WrapLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button(item) { onTap(item) }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.tertiarySystemFill), in: Capsule())
                    .buttonStyle(.plain)
            }
        }
    }
}

struct WrapLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, maxX: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            maxX = max(maxX, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxX, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
