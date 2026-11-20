//
//  WasteType.swift
//  MapTrash
//
//  Source unique de vérité pour les types de conteneurs (nom, icône, couleur, conseil).
//

import SwiftUI
import UIKit

enum WasteType: String, CaseIterable, Codable, Identifiable, Hashable, Sendable {
    case glass = "VERRE"
    case paper = "PAPIER"
    case packaging = "EMBALLAGES MENAGERS"
    case textile = "TEXTILE"
    case household = "ORDURES MENAGERES"

    var id: String { rawValue }

    /// Nom court (puces, marqueurs).
    var name: String {
        switch self {
        case .glass: "Verre"
        case .paper: "Papier"
        case .packaging: "Emballages"
        case .textile: "Textile"
        case .household: "Ordures"
        }
    }

    /// Nom complet (fiches, Siri).
    var fullName: String {
        switch self {
        case .glass: "Verre"
        case .paper: "Papier"
        case .packaging: "Emballages ménagers"
        case .textile: "Textile"
        case .household: "Ordures ménagères"
        }
    }

    var icon: String {
        switch self {
        case .glass: "wineglass.fill"
        case .paper: "newspaper.fill"
        case .packaging: "bag.fill"
        case .textile: "tshirt.fill"
        case .household: "trash.fill"
        }
    }

    var uiColor: UIColor {
        switch self {
        case .glass: UIColor(red: 0.16, green: 0.66, blue: 0.38, alpha: 1)
        case .paper: UIColor(red: 0.96, green: 0.55, blue: 0.13, alpha: 1)
        case .packaging: UIColor(red: 0.93, green: 0.73, blue: 0.00, alpha: 1)
        case .textile: UIColor(red: 0.25, green: 0.47, blue: 0.95, alpha: 1)
        case .household: UIColor(red: 0.85, green: 0.27, blue: 0.27, alpha: 1)
        }
    }

    var color: Color { Color(uiColor: uiColor) }

    var tip: String {
        switch self {
        case .glass: "Bouteilles, pots et bocaux en vrac, bien vidés, sans bouchon ni couvercle. Inutile de les laver."
        case .paper: "Journaux, magazines, enveloppes et cahiers, sans film plastique."
        case .packaging: "Tous les emballages bien vidés (sans les laver) : plastique, carton, métal, briques. En vrac, pas dans un sac fermé."
        case .textile: "Vêtements, linge et chaussures (liées par paire), propres et secs, dans un sac fermé."
        case .household: "Déchets non recyclables uniquement : restes alimentaires, emballages souillés… dans un sac fermé."
        }
    }
}
