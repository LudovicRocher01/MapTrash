//
//  FavoritesStore.swift
//  MapTrash
//
//  Favoris stockés uniquement sur l'appareil (UserDefaults).
//

import Foundation
import Observation

@MainActor
@Observable
final class FavoritesStore {
    private static let key = "favoriteContainerIDs"
    private let defaults: UserDefaults

    private(set) var ids: Set<String>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        ids = Set(defaults.stringArray(forKey: Self.key) ?? [])
    }

    func contains(_ container: Container) -> Bool { ids.contains(container.id) }

    func toggle(_ container: Container) {
        if ids.contains(container.id) { ids.remove(container.id) } else { ids.insert(container.id) }
        defaults.set(Array(ids), forKey: Self.key)
    }
}
