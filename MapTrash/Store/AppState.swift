//
//  AppState.swift
//  MapTrash
//
//  État central : données, filtres, sélection, itinéraire, commandes caméra.
//

import Foundation
import MapKit
import Observation

enum MapSelection: Hashable {
    case container(Container)
    case center(RecyclingCenter)

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .container(let c): c.coordinate
        case .center(let c): c.coordinate
        }
    }

    var annotationID: String {
        switch self {
        case .container(let c): "c-" + c.id
        case .center(let c): "r-" + c.id
        }
    }
}

/// Ordre envoyé à la carte (identifiant unique pour pouvoir répéter le même ordre).
struct CameraCommand: Equatable {
    enum Kind: Equatable {
        case focus(CLLocationCoordinate2D, span: CLLocationDegrees)
        case fit(MKMapRect)
        case userLocation

        static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case let (.focus(a, s1), .focus(b, s2)): a.latitude == b.latitude && a.longitude == b.longitude && s1 == s2
            case let (.fit(a), .fit(b)): MKMapRectEqualToRect(a, b)
            case (.userLocation, .userLocation): true
            default: false
            }
        }
    }
    let id = UUID()
    let kind: Kind
}

@MainActor
@Observable
final class AppState {
    // Données
    private(set) var containers: [Container] = []
    private(set) var centers: [RecyclingCenter] = []
    private(set) var isLoaded = false

    // Filtres (mémorisés)
    var enabledTypes: Set<WasteType> {
        didSet { UserDefaults.standard.set(enabledTypes.map(\.rawValue), forKey: "enabledTypes") }
    }
    var showCenters: Bool {
        didSet { UserDefaults.standard.set(showCenters, forKey: "showCenters") }
    }

    // Sélection et itinéraire
    var selection: MapSelection? {
        didSet { if oldValue != selection { route = nil; routeError = nil } }
    }
    private(set) var route: MKRoute?
    private(set) var routeError: String?
    private(set) var isComputingRoute = false

    var cameraCommand: CameraCommand?

    let favorites = FavoritesStore()

    static let niceCenter = CLLocationCoordinate2D(latitude: 43.7034, longitude: 7.2663)

    init() {
        let defaults = UserDefaults.standard
        if let saved = defaults.stringArray(forKey: "enabledTypes") {
            enabledTypes = Set(saved.compactMap(WasteType.init(rawValue:)))
        } else {
            enabledTypes = Set(WasteType.allCases)
        }
        showCenters = defaults.object(forKey: "showCenters") as? Bool ?? true
    }

    func load() async {
        guard !isLoaded else { return }
        async let loadedContainers = Task.detached(priority: .userInitiated) { ContainerRepository.loadBundled() }.value
        async let loadedCenters = Task.detached(priority: .userInitiated) { RecyclingCenter.loadBundled() }.value
        containers = await loadedContainers
        centers = await loadedCenters
        isLoaded = true
    }

    // MARK: Filtres

    func toggle(_ type: WasteType) {
        if enabledTypes.contains(type) { enabledTypes.remove(type) } else { enabledTypes.insert(type) }
        if case .container(let c) = selection, !enabledTypes.contains(c.type) { selection = nil }
    }

    // MARK: Requêtes de proximité

    func nearest(_ type: WasteType, from location: CLLocation) -> (container: Container, distance: CLLocationDistance)? {
        guard let c = ContainerRepository.nearest(type, in: containers, from: location) else { return nil }
        return (c, c.location.distance(from: location))
    }

    func nearby(from location: CLLocation, limit: Int = 20) -> [(container: Container, distance: CLLocationDistance)] {
        containers
            .filter { enabledTypes.contains($0.type) }
            .map { ($0, $0.location.distance(from: location)) }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { (container: $0.0, distance: $0.1) }
    }

    func nearestCenter(from location: CLLocation?) -> RecyclingCenter? {
        guard let location else { return centers.first { $0.shortName == "Nice Nord" } ?? centers.first }
        return centers.min { $0.clLocation.distance(from: location) < $1.clLocation.distance(from: location) }
    }

    func favoriteContainers(from location: CLLocation?) -> [(container: Container, distance: CLLocationDistance?)] {
        let favs = containers.filter { favorites.ids.contains($0.id) }
        let mapped = favs.map { (container: $0, distance: location.map($0.location.distance(from:))) }
        return mapped.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    // MARK: Actions

    func select(_ newSelection: MapSelection, zoom: Bool = true) {
        if case .container(let c) = newSelection, !enabledTypes.contains(c.type) {
            enabledTypes.insert(c.type)
        }
        if case .center = newSelection, !showCenters { showCenters = true }
        selection = newSelection
        if zoom {
            cameraCommand = CameraCommand(kind: .focus(newSelection.coordinate, span: 0.006))
        }
    }

    /// Sélectionne le conteneur le plus proche d'un type (Siri, widget, « Où jeter… ? »).
    func selectNearest(_ type: WasteType, from location: CLLocation?, withRoute: Bool = false) {
        let origin = location ?? CLLocation(latitude: Self.niceCenter.latitude, longitude: Self.niceCenter.longitude)
        guard let match = nearest(type, from: origin) else { return }
        select(.container(match.container))
        if withRoute, let location { Task { await computeRoute(from: location.coordinate) } }
    }

    func centerOnUser() {
        cameraCommand = CameraCommand(kind: .userLocation)
    }

    func computeRoute(from origin: CLLocationCoordinate2D) async {
        guard let selection else { return }
        isComputingRoute = true
        routeError = nil
        defer { isComputingRoute = false }
        let isCenter: Bool = if case .center = selection { true } else { false }
        do {
            let result = try await RouteService.walkingRoute(
                from: origin,
                to: selection.coordinate,
                transport: isCenter ? .automobile : .walking
            )
            guard self.selection == selection else { return }
            route = result
            if let result {
                cameraCommand = CameraCommand(kind: .fit(result.polyline.boundingMapRect))
            }
        } catch {
            routeError = "Itinéraire indisponible pour le moment."
        }
    }

    func clearRoute() {
        route = nil
    }
}
