//
//  RouteService.swift
//  MapTrash
//
//  Itinéraires à pied (Apple Plans) et ouverture dans une app de navigation externe.
//

import MapKit
import UIKit

enum RouteService {
    static func walkingRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, transport: MKDirectionsTransportType = .walking) async throws -> MKRoute? {
        let request = MKDirections.Request()
        request.source = mapItem(origin)
        request.destination = mapItem(destination)
        request.transportType = transport
        let response = try await MKDirections(request: request).calculate()
        return response.routes.first
    }

    static func mapItem(_ coordinate: CLLocationCoordinate2D) -> MKMapItem {
        if #available(iOS 26, *) {
            return MKMapItem(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), address: nil)
        }
        return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
    }

    static var hasGoogleMaps: Bool {
        guard let url = URL(string: "comgooglemaps://") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    static func openInAppleMaps(_ destination: CLLocationCoordinate2D, name: String, walking: Bool = true) {
        let item = mapItem(destination)
        item.name = name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: walking ? MKLaunchOptionsDirectionsModeWalking : MKLaunchOptionsDirectionsModeDriving
        ])
    }

    static func openInGoogleMaps(_ destination: CLLocationCoordinate2D, walking: Bool = true) {
        let daddr = "\(destination.latitude),\(destination.longitude)"
        let mode = walking ? "walking" : "driving"
        if hasGoogleMaps, let url = URL(string: "comgooglemaps://?daddr=\(daddr)&directionsmode=\(mode)") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(daddr)&travelmode=\(mode)") {
            UIApplication.shared.open(url)
        }
    }
}
