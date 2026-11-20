//
//  ContentView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 18/03/2025.
//

import SwiftUI
import MapKit

extension PresentationDetent {
    static let compact = PresentationDetent.height(176)
}

struct ContentView: View {
    @Environment(AppState.self) private var app
    @Environment(LocationManager.self) private var location
    @Environment(AppRouter.self) private var router

    @State private var detent: PresentationDetent = .compact
    @State private var screenHeight: CGFloat = 800

    private var sheetHeight: CGFloat {
        switch detent {
        case .compact: 176
        case .large: screenHeight * 0.9
        default: screenHeight * 0.5
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            ClusteredMapView(
                containers: app.containers,
                centers: app.centers,
                enabledTypes: app.enabledTypes,
                showCenters: app.showCenters,
                selection: app.selection,
                route: app.route,
                cameraCommand: app.cameraCommand,
                bottomInset: min(sheetHeight, screenHeight * 0.5),
                onSelect: { selection in
                    withAnimation(.snappy) { app.selection = selection }
                }
            )
            .ignoresSafeArea()

            mapControls
        }
        .overlay(alignment: .top) {
            if !app.isLoaded {
                ProgressView("Chargement des conteneurs…")
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .glassPanel(cornerRadius: 16)
                    .padding(.top, 8)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { screenHeight = $0 }
        .sheet(isPresented: .constant(true)) {
            BottomSheet(detent: $detent)
                .presentationDetents([.compact, .medium, .large], selection: $detent)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
        }
        .sensoryFeedback(.selection, trigger: app.selection)
        .task {
            location.start()
            await app.load()
            #if DEBUG
            // Tests : xcrun simctl launch <device> <bundle> -debugURL "maptrash://nearest?type=VERRE"
            if let debugURL = UserDefaults.standard.string(forKey: "debugURL"), let url = URL(string: debugURL) {
                try? await Task.sleep(for: .seconds(2))
                router.handle(url)
            }
            if UserDefaults.standard.bool(forKey: "debugCenter"), let c = app.nearestCenter(from: location.location) {
                app.select(.center(c))
            }
            #endif
            handlePendingRoute()
        }
        .onChange(of: router.pending) { handlePendingRoute() }
        .onChange(of: location.location) { old, new in
            // Premier point GPS : on centre la carte sur l'utilisateur.
            if old == nil, let new, app.selection == nil {
                app.cameraCommand = CameraCommand(kind: .focus(new.coordinate, span: 0.012))
            }
        }
        .onChange(of: app.selection) { _, newValue in
            if newValue != nil, detent == .compact { detent = .medium }
        }
    }

    // MARK: Boutons flottants

    private var mapControls: some View {
        GlassGroup {
            VStack(spacing: 10) {
                Button {
                    if location.isAuthorized { app.centerOnUser() } else { location.start() }
                } label: {
                    Image(systemName: location.isAuthorized ? "location.fill" : "location.slash")
                        .font(.system(size: 18, weight: .semibold))
                        .glassCircle()
                }
                .accessibilityLabel("Centrer sur ma position")

                Button {
                    withAnimation(.snappy) { app.showCenters.toggle() }
                } label: {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(app.showCenters ? Color.brown : Color.secondary)
                        .glassCircle()
                }
                .accessibilityLabel(app.showCenters ? "Masquer les déchetteries" : "Afficher les déchetteries")
            }
        }
        .tint(.primary)
        .padding(.trailing, 14)
        .padding(.top, 8)
    }

    // MARK: Siri / widget

    private func handlePendingRoute() {
        guard app.isLoaded, let pending = router.pending else { return }
        router.pending = nil
        switch pending {
        case .nearest(let type):
            app.selectNearest(type, from: location.location, withRoute: location.location != nil)
        case .container(let id):
            if let c = app.containers.first(where: { $0.id == id }) { app.select(.container(c)) }
        }
        detent = .medium
    }
}

#Preview {
    ContentView()
        .environment(AppState())
        .environment(LocationManager())
        .environment(AppRouter.shared)
}
