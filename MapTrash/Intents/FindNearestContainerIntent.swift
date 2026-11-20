//
//  FindNearestContainerIntent.swift
//  MapTrash
//
//  « Dis Siri, où est le conteneur à verre le plus proche avec Tri Nice ? »
//

import AppIntents

struct FindNearestContainerIntent: AppIntent {
    static let title: LocalizedStringResource = "Trouver le conteneur le plus proche"
    static let description = IntentDescription("Ouvre Tri Nice sur le conteneur le plus proche du type choisi, avec l'itinéraire à pied.")
    static let openAppWhenRun = true

    @Parameter(title: "Type de conteneur", default: .glass)
    var type: WasteType

    static var parameterSummary: some ParameterSummary {
        Summary("Trouver le conteneur \(\.$type) le plus proche")
    }

    init() {}

    init(type: WasteType) {
        self.type = type
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        AppRouter.shared.pending = .nearest(type)
        return .result()
    }
}

struct MapTrashShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FindNearestContainerIntent(),
            phrases: [
                "Trouver un conteneur \(\.$type) avec \(.applicationName)",
                "Où est le conteneur \(\.$type) le plus proche avec \(.applicationName)",
                "Conteneur \(\.$type) le plus proche dans \(.applicationName)",
                "Où jeter mon \(\.$type) avec \(.applicationName)",
            ],
            shortTitle: "Conteneur le plus proche",
            systemImageName: "location.magnifyingglass"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .teal
}
