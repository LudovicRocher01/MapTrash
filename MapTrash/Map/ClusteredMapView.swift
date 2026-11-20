//
//  ClusteredMapView.swift
//  MapTrash
//
//  MKMapView avec regroupement natif : affiche ~3 000 conteneurs sans ralentir.
//  Les annotations sont créées une seule fois ; un changement de filtre ne fait
//  qu'ajouter / retirer le groupe concerné.
//

import SwiftUI
import MapKit

// MARK: - Annotations

final class ContainerAnnotation: NSObject, MKAnnotation {
    let container: Container
    let coordinate: CLLocationCoordinate2D
    var title: String? { container.type.fullName }
    var subtitle: String? { container.displayAddress }

    init(_ container: Container) {
        self.container = container
        self.coordinate = container.coordinate
    }
}

final class RecyclingCenterAnnotation: NSObject, MKAnnotation {
    let center: RecyclingCenter
    let coordinate: CLLocationCoordinate2D
    var title: String? { center.name }

    init(_ center: RecyclingCenter) {
        self.center = center
        self.coordinate = center.coordinate
    }
}

// MARK: - Vues d'annotation

final class ContainerMarkerView: MKMarkerAnnotationView {
    static let reuseID = "container"

    override var annotation: MKAnnotation? {
        didSet { configure() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        configure()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func configure() {
        guard let annotation = annotation as? ContainerAnnotation else { return }
        let type = annotation.container.type
        clusteringIdentifier = type.rawValue
        markerTintColor = type.uiColor
        glyphImage = UIImage(systemName: type.icon)
        displayPriority = .defaultLow
        titleVisibility = .hidden
        subtitleVisibility = .hidden
        isAccessibilityElement = true
        accessibilityLabel = "Conteneur \(type.fullName), \(annotation.container.displayAddress)"
    }
}

final class ContainerClusterView: MKAnnotationView {
    static let reuseID = "cluster"
    private let size: CGFloat = 38

    override var annotation: MKAnnotation? {
        didSet { setNeedsDisplayForCluster() }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        displayPriority = .defaultHigh
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        setNeedsDisplayForCluster()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setNeedsDisplayForCluster() {
        guard let cluster = annotation as? MKClusterAnnotation,
              let first = cluster.memberAnnotations.first as? ContainerAnnotation else { return }
        let type = first.container.type
        let count = cluster.memberAnnotations.count
        let diameter = size + min(CGFloat(count), 200) / 200 * 14
        frame.size = CGSize(width: diameter, height: diameter)
        image = Self.render(count: count, color: type.uiColor, icon: type.icon, diameter: diameter)
        isAccessibilityElement = true
        accessibilityLabel = "\(count) conteneurs \(type.fullName)"
    }

    private static func render(count: Int, color: UIColor, icon: String, diameter: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { _ in
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            UIColor.white.setFill()
            UIBezierPath(ovalIn: rect).fill()
            color.setFill()
            UIBezierPath(ovalIn: rect.insetBy(dx: 2.5, dy: 2.5)).fill()

            let text = count > 999 ? "999+" : "\(count)"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: diameter * 0.36, weight: .bold),
                .foregroundColor: UIColor.white,
            ]
            let textSize = text.size(withAttributes: attrs)
            text.draw(at: CGPoint(x: (diameter - textSize.width) / 2, y: (diameter - textSize.height) / 2), withAttributes: attrs)
        }
    }
}

final class RecyclingCenterMarkerView: MKMarkerAnnotationView {
    static let reuseID = "center"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        markerTintColor = .systemBrown
        glyphImage = UIImage(systemName: "building.2.fill")
        displayPriority = .required
        titleVisibility = .adaptive
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override var annotation: MKAnnotation? {
        didSet { accessibilityLabel = (annotation as? RecyclingCenterAnnotation)?.center.name }
    }
}

// MARK: - Représentable

struct ClusteredMapView: UIViewRepresentable {
    let containers: [Container]
    let centers: [RecyclingCenter]
    let enabledTypes: Set<WasteType>
    let showCenters: Bool
    let selection: MapSelection?
    let route: MKRoute?
    let cameraCommand: CameraCommand?
    var bottomInset: CGFloat = 0
    let onSelect: (MapSelection?) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onSelect: onSelect) }

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.showsCompass = true
        map.pointOfInterestFilter = .excludingAll
        map.register(ContainerMarkerView.self, forAnnotationViewWithReuseIdentifier: ContainerMarkerView.reuseID)
        map.register(ContainerClusterView.self, forAnnotationViewWithReuseIdentifier: ContainerClusterView.reuseID)
        map.register(RecyclingCenterMarkerView.self, forAnnotationViewWithReuseIdentifier: RecyclingCenterMarkerView.reuseID)
        map.setRegion(
            MKCoordinateRegion(center: AppState.niceCenter, span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)),
            animated: false
        )
        context.coordinator.mapView = map
        return map
    }

    func updateUIView(_ map: MKMapView, context: Context) {
        let coordinator = context.coordinator
        coordinator.onSelect = onSelect
        coordinator.bottomInset = bottomInset
        coordinator.syncData(containers: containers, centers: centers)
        coordinator.syncFilters(enabledTypes: enabledTypes, showCenters: showCenters)
        coordinator.syncRoute(route)
        coordinator.syncCamera(cameraCommand)
        coordinator.syncSelection(selection)
    }

    // MARK: Coordinator

    @MainActor
    final class Coordinator: NSObject, MKMapViewDelegate {
        weak var mapView: MKMapView?
        var onSelect: (MapSelection?) -> Void
        var bottomInset: CGFloat = 0

        private var loadedCount = -1
        private var annotationsByType: [WasteType: [ContainerAnnotation]] = [:]
        private var annotationByID: [String: MKAnnotation] = [:]
        private var centerAnnotations: [RecyclingCenterAnnotation] = []
        private var visibleTypes: Set<WasteType> = []
        private var centersVisible = false
        private var currentRoute: MKRoute?
        private var lastCameraID: UUID?
        private var currentSelectionID: String?
        private var isApplyingSelection = false
        private var pendingSelection: MKAnnotation?

        init(onSelect: @escaping (MapSelection?) -> Void) {
            self.onSelect = onSelect
        }

        // Données : construites une seule fois.
        func syncData(containers: [Container], centers: [RecyclingCenter]) {
            guard let map = mapView, containers.count + centers.count != loadedCount else { return }
            map.removeAnnotations(map.annotations.filter { !($0 is MKUserLocation) })
            annotationsByType = Dictionary(grouping: containers.map(ContainerAnnotation.init), by: { $0.container.type })
            centerAnnotations = centers.map(RecyclingCenterAnnotation.init)
            annotationByID = [:]
            for list in annotationsByType.values { for a in list { annotationByID["c-" + a.container.id] = a } }
            for a in centerAnnotations { annotationByID["r-" + a.center.id] = a }
            visibleTypes = []
            centersVisible = false
            loadedCount = containers.count + centers.count
        }

        // Filtres : diff par groupe.
        func syncFilters(enabledTypes: Set<WasteType>, showCenters: Bool) {
            guard let map = mapView else { return }
            for type in visibleTypes.subtracting(enabledTypes) {
                map.removeAnnotations(annotationsByType[type] ?? [])
            }
            for type in enabledTypes.subtracting(visibleTypes) {
                map.addAnnotations(annotationsByType[type] ?? [])
            }
            visibleTypes = enabledTypes

            if showCenters != centersVisible {
                if showCenters { map.addAnnotations(centerAnnotations) } else { map.removeAnnotations(centerAnnotations) }
                centersVisible = showCenters
            }
        }

        func syncRoute(_ route: MKRoute?) {
            guard let map = mapView, route !== currentRoute else { return }
            if let old = currentRoute { map.removeOverlay(old.polyline) }
            if let route { map.addOverlay(route.polyline, level: .aboveRoads) }
            currentRoute = route
        }

        func syncCamera(_ command: CameraCommand?) {
            guard let map = mapView, let command, command.id != lastCameraID else { return }
            lastCameraID = command.id
            let padding = UIEdgeInsets(top: 110, left: 50, bottom: bottomInset + 80, right: 70)
            switch command.kind {
            case .focus(let coordinate, let span):
                let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span))
                // Décale le centre pour que le point reste visible au-dessus de la feuille.
                let rect = Self.mapRect(for: region)
                map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0), animated: true)
            case .fit(let rect):
                map.setVisibleMapRect(rect, edgePadding: padding, animated: true)
            case .userLocation:
                if let loc = map.userLocation.location {
                    let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 600, longitudinalMeters: 600)
                    map.setVisibleMapRect(Self.mapRect(for: region), edgePadding: UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0), animated: true)
                }
            }
        }

        func syncSelection(_ selection: MapSelection?) {
            guard let map = mapView else { return }
            let id = selection?.annotationID
            guard id != currentSelectionID else { return }
            currentSelectionID = id
            isApplyingSelection = true
            defer { isApplyingSelection = false }
            if let id, let annotation = annotationByID[id] {
                map.selectAnnotation(annotation, animated: true)
                // Si le point est encore regroupé, on réessaie une fois la caméra arrivée.
                pendingSelection = map.selectedAnnotations.contains { $0 === annotation } ? nil : annotation
            } else {
                pendingSelection = nil
                for a in map.selectedAnnotations { map.deselectAnnotation(a, animated: true) }
            }
        }

        private static func mapRect(for region: MKCoordinateRegion) -> MKMapRect {
            let topLeft = MKMapPoint(CLLocationCoordinate2D(latitude: region.center.latitude + region.span.latitudeDelta / 2,
                                                            longitude: region.center.longitude - region.span.longitudeDelta / 2))
            let bottomRight = MKMapPoint(CLLocationCoordinate2D(latitude: region.center.latitude - region.span.latitudeDelta / 2,
                                                                longitude: region.center.longitude + region.span.longitudeDelta / 2))
            return MKMapRect(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y),
                             width: abs(topLeft.x - bottomRight.x), height: abs(topLeft.y - bottomRight.y))
        }

        // MARK: MKMapViewDelegate

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case is MKUserLocation:
                return nil
            case is MKClusterAnnotation:
                return mapView.dequeueReusableAnnotationView(withIdentifier: ContainerClusterView.reuseID, for: annotation)
            case is ContainerAnnotation:
                return mapView.dequeueReusableAnnotationView(withIdentifier: ContainerMarkerView.reuseID, for: annotation)
            case is RecyclingCenterAnnotation:
                return mapView.dequeueReusableAnnotationView(withIdentifier: RecyclingCenterMarkerView.reuseID, for: annotation)
            default:
                return nil
            }
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let cluster = annotation as? MKClusterAnnotation {
                mapView.deselectAnnotation(cluster, animated: false)
                let rect = cluster.memberAnnotations.reduce(MKMapRect.null) { partial, member in
                    partial.union(MKMapRect(origin: MKMapPoint(member.coordinate), size: MKMapSize(width: 1, height: 1)))
                }
                mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 60, bottom: bottomInset + 60, right: 60), animated: true)
                return
            }
            guard !isApplyingSelection else { return }
            let selection: MapSelection? = switch annotation {
            case let a as ContainerAnnotation: .container(a.container)
            case let a as RecyclingCenterAnnotation: .center(a.center)
            default: nil
            }
            guard let selection else { return }
            currentSelectionID = selection.annotationID
            onSelect(selection)
        }

        func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
            guard !isApplyingSelection, !(annotation is MKClusterAnnotation) else { return }
            // Laisse le temps à une éventuelle nouvelle sélection d'arriver.
            DispatchQueue.main.async { [weak self, weak mapView] in
                guard let self, let mapView, mapView.selectedAnnotations.isEmpty, self.currentSelectionID != nil else { return }
                self.currentSelectionID = nil
                self.onSelect(nil)
            }
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            guard let pending = pendingSelection else { return }
            pendingSelection = nil
            isApplyingSelection = true
            mapView.selectAnnotation(pending, animated: true)
            isApplyingSelection = false
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer(overlay: overlay) }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 6
            renderer.lineCap = .round
            renderer.lineJoin = .round
            return renderer
        }
    }
}
