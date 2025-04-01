//
//  Container.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 18/03/2025.
//

import Foundation
import CoreLocation
import SwiftUI

struct ContainerData: Codable {
    let features: [ContainerFeature]
}

struct ContainerFeature: Codable {
    let geometry: Geometry
    let properties: ContainerProperties
}

struct Geometry: Codable {
    let coordinates: [Double]
}

struct ContainerProperties: Codable {
    let type: String

    enum CodingKeys: String, CodingKey {
        case type = "CONTENEUR"
    }
}

struct Container: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: String
    
    func getColor() -> Color {
        switch type.uppercased() {
        case "VERRE":
            return .green
        case "TEXTILE":
            return .blue
        case "EMBALLAGES MENAGERS":
            return .yellow
        case "ORDURES MENAGERES":
            return .red
        case "PAPIER":
            return .orange
        default:
            return .gray
        }
    }
    
    func getRecyclingTip() -> String {
        switch type.uppercased() {
        case "VERRE":
            return "Déposez vos bouteilles, pots et bocaux en vrac, bien vidés, sans bouchon et sans prélavage."
        case "TEXTILE":
            return "Déposez vêtements, chaussures liées par paire, sacs et linge propre et sec dans des sacs fermés."
        case "EMBALLAGES MENAGERS":
            return "Tous les emballages vidés (non lavés) sont acceptés : plastique, carton, métal, briques."
        case "ORDURES MENAGERES":
            return "Déchets non recyclables : restes alimentaires, plastiques souillés, etc."
        case "PAPIER":
            return "Déposez journaux, magazines, enveloppes et cahiers sans film plastique."
        default:
            return "Merci de trier vos déchets selon les consignes locales."
        }
    }

}
