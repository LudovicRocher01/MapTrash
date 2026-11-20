//
//  SortingGuide+Display.swift
//  MapTrash
//
//  Données de présentation du guide : exemples courts et chiffres clés.
//

import Foundation

struct GuideStat: Hashable {
    let value: String
    let label: String
}

extension GuideEntry {
    /// Résumé court affiché sur la tuile.
    var examples: String {
        switch id {
        case "glass": "Bouteilles, pots, bocaux"
        case "paper": "Journaux, courriers, cahiers"
        case "packaging": "Plastiques, cartons, métal"
        case "textile": "Vêtements, linge, chaussures"
        case "household": "Ce qui ne se recycle pas"
        case "best": "Réduire, réutiliser, composter"
        default: ""
        }
    }

    /// Chiffres clés (repris des textes « Le saviez-vous ? »).
    var stats: [GuideStat] {
        switch id {
        case "glass": [
            GuideStat(value: "∞", label: "recyclable à l'infini"),
            GuideStat(value: "700 kg", label: "de sable économisés par tonne"),
            GuideStat(value: "−25 %", label: "d'énergie"),
        ]
        case "paper": [
            GuideStat(value: "17", label: "arbres sauvés par tonne"),
            GuideStat(value: "20 000 L", label: "d'eau économisés"),
            GuideStat(value: "−60 %", label: "d'énergie"),
        ]
        case "packaging": [
            GuideStat(value: "5 Mt", label: "recyclées par an en France"),
            GuideStat(value: "−95 %", label: "d'énergie pour l'alu"),
        ]
        case "textile": [
            GuideStat(value: "2 700 L", label: "d'eau pour un t-shirt"),
            GuideStat(value: "Même", label: "usés ou troués"),
        ]
        case "household": [
            GuideStat(value: "582 kg", label: "de déchets par habitant et par an"),
            GuideStat(value: "50 %", label: "finissent encore aux ordures"),
        ]
        default: []
        }
    }
}

enum GuideFacts {
    static let all: [String] = [
        "Le verre se recycle à l'infini, sans perte de qualité.",
        "Inutile de laver vos emballages : il suffit de bien les vider.",
        "Ne mettez pas vos emballages dans un sac fermé : déposez-les en vrac.",
        "Une tonne de papier recyclé sauve jusqu'à 17 arbres.",
        "Recycler l'aluminium économise jusqu'à 95 % d'énergie.",
        "Les vêtements usés ou troués se déposent aussi dans le conteneur textile.",
        "La vaisselle cassée ne va pas dans le conteneur à verre, mais aux ordures.",
        "Les enveloppes à fenêtre se recyclent avec le papier.",
        "Un mégot jeté par terre peut polluer jusqu'à 500 litres d'eau.",
        "Les piles se rapportent dans les bacs de collecte en magasin.",
    ]
}
