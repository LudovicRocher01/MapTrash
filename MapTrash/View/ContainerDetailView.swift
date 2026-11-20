//
//  ContainerDetailView.swift
//  MapTrash
//

import SwiftUI
import MapKit

struct ContainerDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    let container: Container
    let onOpenGuide: () -> Void

    private var distance: CLLocationDistance? {
        location.location.map { container.location.distance(from: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailHeader(
                icon: container.type.icon,
                color: container.type.color,
                title: container.type.fullName,
                subtitle: container.displayAddress,
                isFavorite: app.favorites.contains(container),
                onFavorite: { app.favorites.toggle(container) },
                onClose: { app.selection = nil }
            )

            // Infos
            FlowTags(tags: [
                ("mappin.and.ellipse", container.commune),
                container.kindLabel.map { ("shippingbox", $0) },
                container.collectionDay.map { ("calendar", "Collecte : \($0.lowercased())") },
            ].compactMap { $0 })

            // Distance / itinéraire
            RouteBlock(
                coordinate: container.coordinate,
                name: "\(container.type.fullName) – \(container.displayAddress)",
                straightDistance: distance,
                walking: true
            )

            // Conseil
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text(container.type.tip)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tileBackground()

            Button(action: onOpenGuide) {
                Label("Que mettre dans ce conteneur ?", systemImage: "book")
                    .font(.subheadline.weight(.semibold))
            }
        }
    }
}

// MARK: - Composants partagés par les fiches

struct DetailHeader: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    var isFavorite: Bool? = nil
    var onFavorite: (() -> Void)? = nil
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(icon: icon, color: color, size: 50)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 4)
            if let isFavorite, let onFavorite {
                Button(action: onFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isFavorite ? .yellow : .secondary)
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemFill), in: Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                .sensoryFeedback(.success, trigger: isFavorite)
                .accessibilityLabel(isFavorite ? "Retirer des favoris" : "Ajouter aux favoris")
            }
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color(.tertiarySystemFill), in: Circle())
            }
            .accessibilityLabel("Fermer")
        }
    }
}

struct FlowTags: View {
    let tags: [(String, String)]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { content }
            VStack(alignment: .leading, spacing: 8) { content }
        }
    }

    @ViewBuilder
    private var content: some View {
        ForEach(tags, id: \.1) { icon, text in
            Label(text, systemImage: icon)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill), in: Capsule())
        }
    }
}

/// Distance, temps, bouton itinéraire et ouverture dans une app externe.
struct RouteBlock: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location

    let coordinate: CLLocationCoordinate2D
    let name: String
    let straightDistance: CLLocationDistance?
    let walking: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let route = app.route {
                HStack(spacing: 16) {
                    metric(DistanceFormatter.duration(seconds: route.expectedTravelTime), label: walking ? "à pied" : "en voiture", icon: walking ? "figure.walk" : "car.fill")
                    metric(DistanceFormatter.distance(route.distance), label: "trajet", icon: "point.topleft.down.to.point.bottomright.curvepath")
                }
            } else if let straightDistance {
                HStack(spacing: 16) {
                    metric(DistanceFormatter.distance(straightDistance), label: "à vol d'oiseau", icon: "location")
                    if walking {
                        metric("≈ " + DistanceFormatter.walkingTime(straightDistance), label: "à pied", icon: "figure.walk")
                    }
                }
            }

            if let error = app.routeError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 10) {
                if app.route == nil {
                    Button {
                        guard let here = location.location?.coordinate else { location.start(); return }
                        Task { await app.computeRoute(from: here) }
                    } label: {
                        Group {
                            if app.isComputingRoute {
                                ProgressView().tint(.white)
                            } else {
                                Label("Itinéraire", systemImage: walking ? "figure.walk" : "car.fill")
                            }
                        }
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 34)
                    }
                    .prominentButtonStyle(tint: .blue)
                    .disabled(app.isComputingRoute || !location.isAuthorized)
                } else {
                    Button {
                        withAnimation { app.clearRoute() }
                    } label: {
                        Label("Masquer l'itinéraire", systemImage: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 34)
                    }
                    .secondaryButtonStyle()
                }

                Menu {
                    Button {
                        RouteService.openInAppleMaps(coordinate, name: name, walking: walking)
                    } label: {
                        Label("Plans", systemImage: "map")
                    }
                    Button {
                        RouteService.openInGoogleMaps(coordinate, walking: walking)
                    } label: {
                        Label("Google Maps", systemImage: "globe")
                    }
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                        .font(.body.weight(.semibold))
                        .frame(width: 34, height: 34)
                }
                .secondaryButtonStyle()
                .accessibilityLabel("Ouvrir dans une app de navigation")
            }
        }
    }

    private func metric(_ value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold).monospacedDigit())
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
