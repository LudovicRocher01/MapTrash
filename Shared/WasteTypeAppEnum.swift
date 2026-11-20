//
//  WasteTypeAppEnum.swift
//  MapTrash
//
//  Exposition des types de conteneurs à Siri, Raccourcis et aux widgets.
//

import AppIntents

extension WasteType: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Type de conteneur")
    }

    static var caseDisplayRepresentations: [WasteType: DisplayRepresentation] {
        [
            .glass: DisplayRepresentation(title: "Verre", image: .init(systemName: "wineglass.fill"), synonyms: ["verre", "bouteilles", "conteneur à verre"]),
            .paper: DisplayRepresentation(title: "Papier", image: .init(systemName: "newspaper.fill"), synonyms: ["papier", "journaux"]),
            .packaging: DisplayRepresentation(title: "Emballages", image: .init(systemName: "bag.fill"), synonyms: ["emballages", "plastique", "poubelle jaune"]),
            .textile: DisplayRepresentation(title: "Textile", image: .init(systemName: "tshirt.fill"), synonyms: ["vêtements", "textile", "habits"]),
            .household: DisplayRepresentation(title: "Ordures ménagères", image: .init(systemName: "trash.fill"), synonyms: ["ordures", "poubelle"]),
        ]
    }
}
