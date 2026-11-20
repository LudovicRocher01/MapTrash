//
//  BottomSheet.swift
//  MapTrash
//
//  Feuille persistante : recherche « Où jeter… ? », filtres, à proximité, fiches.
//

import SwiftUI

struct BottomSheet: View {
    @Environment(AppState.self) private var app
    @Binding var detent: PresentationDetent

    @State private var query = ""
    @FocusState private var searchFocused: Bool
    @State private var guide: GuideRoute?

    private var isSearching: Bool { searchFocused || !query.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 10)

            ScrollView {
                Group {
                    if isSearching {
                        WhereToThrowView(query: $query, onDone: endSearch, onOpenGuide: { guide = .home })
                    } else if case .container(let container) = app.selection {
                        ContainerDetailView(container: container, onOpenGuide: { guide = .entry(SortingGuide.entry(for: container.type)) })
                            .id(container.id)
                    } else if case .center(let center) = app.selection {
                        RecyclingCenterDetailView(center: center)
                            .id(center.id)
                    } else {
                        HomePanel()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
                .transition(.opacity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .animation(.snappy, value: app.selection)
        .animation(.snappy, value: isSearching)
        .onChange(of: searchFocused) { _, focused in
            if focused { detent = .large }
        }
        // La feuille étant au premier plan, les liens maptrash:// lui sont livrés.
        .onOpenURL { url in AppRouter.shared.handle(url) }
        #if DEBUG
        .task {
            if let q = UserDefaults.standard.string(forKey: "debugQuery") { query = q; detent = .large }
            if UserDefaults.standard.bool(forKey: "debugMedium") { detent = .large }
            if let g = UserDefaults.standard.string(forKey: "debugGuide") {
                guide = SortingGuide.entries.first { $0.id == g }.map(GuideRoute.entry) ?? .home
            }
        }
        #endif
        .sheet(item: $guide) { route in
            SortingGuideView(initial: route)
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Où jeter… ? (pile, pot de yaourt…)", text: $query)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Effacer")
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color(.tertiarySystemFill), in: Capsule())

            if isSearching {
                Button("Annuler", action: endSearch)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                Button {
                    guide = .home
                } label: {
                    Image(systemName: "book.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(Color(.tertiarySystemFill), in: Circle())
                }
                .tint(.primary)
                .accessibilityLabel("Guide du tri")
            }
        }
    }

    private func endSearch() {
        query = ""
        searchFocused = false
        if detent == .large { detent = .medium }
    }
}

enum GuideRoute: Identifiable, Hashable {
    case home
    case entry(GuideEntry)

    var id: String {
        switch self {
        case .home: "home"
        case .entry(let e): e.id
        }
    }
}
