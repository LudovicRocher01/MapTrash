//
//  AppRouter.swift
//  MapTrash
//
//  Navigation demandée depuis l'extérieur (Siri / Raccourcis / widget / URL).
//

import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    static let shared = AppRouter()

    enum Pending: Equatable {
        case nearest(WasteType)
        case container(id: String)
    }

    var pending: Pending?

    /// maptrash://nearest?type=VERRE  ·  maptrash://container?id=48088V
    func handle(_ url: URL) {
        guard url.scheme == "maptrash",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let value = components.queryItems?.first?.value
        switch url.host {
        case "nearest":
            if let raw = value, let type = WasteType(rawValue: raw) { pending = .nearest(type) }
        case "container":
            if let id = value { pending = .container(id: id) }
        default:
            break
        }
    }
}
