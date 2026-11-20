//
//  RecyclingCenterDetailView.swift
//  MapTrash
//

import SwiftUI
import CoreLocation

struct RecyclingCenterDetailView: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    @Environment(\.openURL) private var openURL
    let center: RecyclingCenter

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailHeader(
                icon: "building.2.fill",
                color: .brown,
                title: center.name,
                subtitle: center.address,
                onClose: { app.selection = nil }
            )

            TimelineView(.periodic(from: .now, by: 60)) { context in
                OpenStateBadge(state: center.openState(at: context.date))
            }

            RouteBlock(
                coordinate: center.coordinate,
                name: center.name,
                straightDistance: location.location.map { center.clLocation.distance(from: $0) },
                walking: false
            )

            VStack(alignment: .leading, spacing: 12) {
                Label {
                    Text(center.hours).fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "clock").foregroundStyle(.secondary)
                }
                if let url = center.phoneURL {
                    Divider()
                    Button {
                        openURL(url)
                    } label: {
                        Label(center.phone, systemImage: "phone.fill")
                    }
                }
            }
            .font(.subheadline)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tileBackground()

            Text("Horaires indicatifs, hors jours fériés. Vérifiez auprès de la Métropole avant de vous déplacer.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct OpenStateBadge: View {
    let state: RecyclingCenter.OpenState
    var compact = false

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isOpen ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(text)
                .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                .foregroundStyle(isOpen ? Color.green : Color.red)
        }
        .padding(.horizontal, compact ? 8 : 12)
        .padding(.vertical, compact ? 3 : 6)
        .background((isOpen ? Color.green : Color.red).opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var isOpen: Bool {
        if case .open = state { return true }
        return false
    }

    private var text: String {
        switch state {
        case .open(let until): "Ouvert · ferme à \(until)"
        case .closed(let next?): "Fermé · ouvre \(next)"
        case .closed(nil): "Fermé"
        }
    }
}
