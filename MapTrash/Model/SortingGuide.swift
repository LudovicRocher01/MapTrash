//
//  SortingGuide.swift
//  MapTrash
//
//  Contenu du guide du tri (remplace les 6 vues *InfoView dupliquées).
//

import SwiftUI

struct GuideItem: Hashable {
    let icon: String
    let text: String
}

struct GuideSection: Hashable {
    enum Style { case accepted, rejected, tips, info }
    let title: String
    let icon: String
    let style: Style
    var items: [GuideItem] = []
    var body: LocalizedStringKey? = nil

    static func == (lhs: GuideSection, rhs: GuideSection) -> Bool { lhs.title == rhs.title }
    func hash(into hasher: inout Hasher) { hasher.combine(title) }

    var tint: Color {
        switch style {
        case .accepted: .green
        case .rejected: .red
        case .tips: .teal
        case .info: .blue
        }
    }
}

struct GuideEntry: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let wasteType: WasteType?
    let sections: [GuideSection]

    static func == (lhs: GuideEntry, rhs: GuideEntry) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum SortingGuide {
    static func entry(for type: WasteType) -> GuideEntry {
        entries.first { $0.wasteType == type }!
    }

    static let entries: [GuideEntry] = [glass, paper, packaging, textile, household, bestPractices]

    static let glass = GuideEntry(
        id: "glass", title: "Verre", subtitle: "Recycler facilement le verre",
        icon: WasteType.glass.icon, color: WasteType.glass.color, wasteType: .glass,
        sections: [
            GuideSection(title: "Ce que vous pouvez jeter", icon: "checkmark.circle.fill", style: .accepted, items: [
                GuideItem(icon: "wineglass.fill", text: "Bouteilles en verre (vin, bière, soda, jus de fruit…)"),
                GuideItem(icon: "cup.and.saucer.fill", text: "Pots, bocaux alimentaires (confitures, sauces, miel…)"),
                GuideItem(icon: "flask.fill", text: "Flacons cosmétiques et pharmaceutiques (parfum, huile essentielle…)"),
            ]),
            GuideSection(title: "À ne surtout pas déposer", icon: "xmark.octagon.fill", style: .rejected, items: [
                GuideItem(icon: "fork.knife.circle.fill", text: "Vaisselle en verre ou porcelaine (verres cassés, assiettes…)"),
                GuideItem(icon: "lightbulb.fill", text: "Ampoules, néons, tubes fluorescents"),
                GuideItem(icon: "rectangle.portrait", text: "Vitres, miroirs, verre armé ou feuilleté"),
                GuideItem(icon: "drop.triangle.fill", text: "Contenants en plastique, métal ou carton"),
            ]),
            GuideSection(title: "Conseils pratiques", icon: "leaf.fill", style: .tips, items: [
                GuideItem(icon: "drop.circle", text: "Bien vider les contenants, mais inutile de les laver."),
                GuideItem(icon: "trash.circle", text: "Déposez le verre directement en vrac, sans sac plastique."),
                GuideItem(icon: "arrow.triangle.2.circlepath", text: "Retirez bouchons et couvercles en métal ou plastique."),
                GuideItem(icon: "exclamationmark.triangle", text: "Évitez absolument de mélanger avec d'autres matériaux."),
            ]),
            GuideSection(title: "Le saviez-vous ?", icon: "globe.europe.africa.fill", style: .info, body: """
Recycler une tonne de verre permet de :
• Réduire la consommation énergétique d'environ **25 %**
• Économiser environ **700 kg de sable**
• Éviter l'émission d'environ **500 kg de CO₂**

Le verre est recyclable à l'infini, sans perte de qualité ni de pureté. Chaque bouteille triée contribue directement à préserver notre planète. 🌱
"""),
        ]
    )

    static let paper = GuideEntry(
        id: "paper", title: "Papier", subtitle: "Recycler efficacement le papier",
        icon: WasteType.paper.icon, color: WasteType.paper.color, wasteType: .paper,
        sections: [
            GuideSection(title: "Papiers à recycler", icon: "checkmark.circle.fill", style: .accepted, items: [
                GuideItem(icon: "newspaper", text: "Journaux, magazines, prospectus, publicités papier"),
                GuideItem(icon: "doc.text.fill", text: "Feuilles de papier, courriers, enveloppes (y compris avec fenêtre)"),
                GuideItem(icon: "book.fill", text: "Cahiers, blocs-notes, livres sans couverture rigide"),
                GuideItem(icon: "envelope.fill", text: "Catalogues, annuaires, guides papier"),
                GuideItem(icon: "doc.on.clipboard.fill", text: "Impressions, documents administratifs sans données sensibles"),
            ]),
            GuideSection(title: "À ne pas déposer", icon: "xmark.octagon.fill", style: .rejected, items: [
                GuideItem(icon: "tray.2.fill", text: "Cartons souillés ou gras (emballages alimentaires très sales)"),
                GuideItem(icon: "sparkles.rectangle.stack.fill", text: "Papier absorbant (essuie-tout, mouchoirs, lingettes)"),
                GuideItem(icon: "photo.fill", text: "Photos, papiers plastifiés, papier cadeau métallisé"),
                GuideItem(icon: "magazine.fill", text: "Couvertures plastifiées ou rigides de livres et cahiers"),
            ]),
            GuideSection(title: "Conseils pratiques", icon: "leaf.fill", style: .tips, items: [
                GuideItem(icon: "envelope.circle", text: "Inutile de retirer la fenêtre plastique des enveloppes : elles sont recyclables !"),
                GuideItem(icon: "doc.circle", text: "Évitez de froisser ou de déchirer excessivement les papiers pour faciliter le tri automatique."),
                GuideItem(icon: "drop.circle", text: "Les papiers souillés ou humides vont dans la poubelle classique."),
                GuideItem(icon: "shield.lefthalf.filled", text: "Détruisez les papiers confidentiels avant recyclage, idéalement avec un broyeur."),
            ]),
            GuideSection(title: "Le saviez-vous ?", icon: "globe.europe.africa.fill", style: .info, body: """
Chaque tonne de papier recyclée permet de sauver :
• Jusqu'à **17 arbres adultes**
• Plus de **20 000 litres d'eau**
• Environ **2,5 tonnes de CO₂**

Le recyclage du papier nécessite **60 % moins d'énergie** que sa production à partir de bois vierge. 🌿
"""),
        ]
    )

    static let packaging = GuideEntry(
        id: "packaging", title: "Emballages", subtitle: "Recycler facilement vos emballages",
        icon: WasteType.packaging.icon, color: WasteType.packaging.color, wasteType: .packaging,
        sections: [
            GuideSection(title: "Emballages à déposer", icon: "checkmark.circle.fill", style: .accepted, items: [
                GuideItem(icon: "cube.box.fill", text: "Cartons et briques alimentaires (lait, jus, soupe)"),
                GuideItem(icon: "cylinder.fill", text: "Boîtes métalliques (conserves, canettes, aérosols vidés)"),
                GuideItem(icon: "bag.fill", text: "Sacs plastiques, emballages plastiques souples"),
                GuideItem(icon: "takeoutbag.and.cup.and.straw.fill", text: "Barquettes, pots et bouteilles en plastique"),
                GuideItem(icon: "film", text: "Film plastique, opercules"),
            ]),
            GuideSection(title: "À ne pas déposer", icon: "xmark.octagon.fill", style: .rejected, items: [
                GuideItem(icon: "trash.slash.fill", text: "Déchets alimentaires"),
                GuideItem(icon: "paintpalette.fill", text: "Emballages souillés par des produits toxiques (peinture, solvants…)"),
                GuideItem(icon: "sparkles.rectangle.stack.fill", text: "Polystyrène expansé (emballages de protection, plateaux repas)"),
                GuideItem(icon: "battery.100", text: "Déchets électroniques, piles, batteries"),
            ]),
            GuideSection(title: "Conseils pratiques", icon: "leaf.fill", style: .tips, items: [
                GuideItem(icon: "drop.circle", text: "Videz complètement les emballages avant de les jeter."),
                GuideItem(icon: "trash.circle", text: "Ne lavez pas les emballages, mais évitez qu'ils soient trop souillés."),
                GuideItem(icon: "arrow.triangle.2.circlepath", text: "Ne mettez pas les emballages dans des sacs fermés (déposez-les en vrac)."),
                GuideItem(icon: "exclamationmark.triangle", text: "Ne les imbriquez pas les uns dans les autres : le tri automatique ne pourrait plus les séparer."),
            ]),
            GuideSection(title: "Le saviez-vous ?", icon: "globe.europe.africa.fill", style: .info, body: """
En France, environ **5 millions de tonnes** d'emballages ménagers sont recyclées chaque année. Recycler vos emballages permet :
• D'économiser des matières premières précieuses (pétrole, bois, minerais…)
• De diminuer la consommation énergétique (jusqu'à **95 %** pour l'aluminium !)
• De limiter considérablement les émissions de gaz à effet de serre 🌿
"""),
        ]
    )

    static let textile = GuideEntry(
        id: "textile", title: "Textile", subtitle: "Recycler les textiles efficacement",
        icon: WasteType.textile.icon, color: WasteType.textile.color, wasteType: .textile,
        sections: [
            GuideSection(title: "Textiles acceptés", icon: "checkmark.circle.fill", style: .accepted, items: [
                GuideItem(icon: "tshirt", text: "Vêtements (même usés ou déchirés)"),
                GuideItem(icon: "bed.double.fill", text: "Linge de maison (draps, rideaux, serviettes…)"),
                GuideItem(icon: "shoeprints.fill", text: "Chaussures (attachées par paires)"),
                GuideItem(icon: "bag.fill", text: "Petite maroquinerie (sacs, ceintures…)"),
                GuideItem(icon: "teddybear.fill", text: "Peluches"),
            ]),
            GuideSection(title: "À ne pas déposer", icon: "xmark.octagon.fill", style: .rejected, items: [
                GuideItem(icon: "paintbrush.fill", text: "Textiles souillés (peinture, produits chimiques…)"),
                GuideItem(icon: "drop.fill", text: "Textiles humides ou moisis"),
                GuideItem(icon: "sofa.fill", text: "Articles encombrants (matelas, tapis, meubles rembourrés…)"),
                GuideItem(icon: "suitcase.fill", text: "Accessoires rigides (casques, valises rigides)"),
            ]),
            GuideSection(title: "Conseils pratiques", icon: "leaf.fill", style: .tips, items: [
                GuideItem(icon: "bag.circle", text: "Déposer les textiles propres et secs, même usés ou troués."),
                GuideItem(icon: "link.circle", text: "Attacher les chaussures par paire (lacets ou élastique)."),
                GuideItem(icon: "shippingbox.fill", text: "Déposer dans des sacs fermés (idéalement réutilisables)."),
                GuideItem(icon: "hands.clap.fill", text: "Favoriser le don si les vêtements sont encore portables."),
            ]),
            GuideSection(title: "Le saviez-vous ?", icon: "globe.europe.africa.fill", style: .info, body: """
Recycler les textiles permet de :
• Réduire considérablement l'impact environnemental de la mode
• Économiser de l'eau (environ **2 700 litres pour un t-shirt**)
• Réduire les émissions de gaz à effet de serre liées à la production textile

La filière crée aussi des emplois locaux dans le tri et le recyclage 🌿.
"""),
        ]
    )

    static let household = GuideEntry(
        id: "household", title: "Ordures ménagères", subtitle: "Gérer les déchets non recyclables",
        icon: WasteType.household.icon, color: WasteType.household.color, wasteType: .household,
        sections: [
            GuideSection(title: "Ce que vous pouvez jeter", icon: "checkmark.circle.fill", style: .accepted, items: [
                GuideItem(icon: "takeoutbag.and.cup.and.straw.fill", text: "Déchets alimentaires non compostés (viande, poisson, produits laitiers…)"),
                GuideItem(icon: "sparkles.rectangle.stack.fill", text: "Emballages très sales ou gras (cartons de pizza très souillés)"),
                GuideItem(icon: "toilet.fill", text: "Mouchoirs et essuie-tout, couches, protections hygiéniques"),
                GuideItem(icon: "trash.slash.fill", text: "Polystyrène, barquettes souillées, petits objets en plastique cassés"),
            ]),
            GuideSection(title: "À ne pas déposer", icon: "xmark.octagon.fill", style: .rejected, items: [
                GuideItem(icon: "battery.100.bolt", text: "Déchets dangereux (piles, batteries, produits chimiques)"),
                GuideItem(icon: "sofa.fill", text: "Encombrants (meubles, électroménager)"),
                GuideItem(icon: "paintbrush.fill", text: "Déchets toxiques (peintures, solvants, huiles moteur)"),
                GuideItem(icon: "leaf.arrow.circlepath", text: "Déchets verts (branchages, herbe, feuilles) → compost ou déchetterie"),
                GuideItem(icon: "lightbulb.fill", text: "Ampoules, néons et appareils électriques ou électroniques"),
            ]),
            GuideSection(title: "Conseils pratiques", icon: "leaf.fill", style: .tips, items: [
                GuideItem(icon: "trash.circle", text: "Ne mélangez jamais déchets dangereux ou électroniques avec les ordures ménagères."),
                GuideItem(icon: "drop.circle", text: "Égouttez bien les restes alimentaires avant de les jeter."),
                GuideItem(icon: "bag.circle", text: "Utilisez des sacs solides et bien fermés pour éviter fuites et odeurs."),
                GuideItem(icon: "arrow.triangle.2.circlepath.circle", text: "Triez un maximum de matières recyclables pour réduire ce sac."),
            ]),
            GuideSection(title: "Le saviez-vous ?", icon: "globe.europe.africa.fill", style: .info, body: """
Chaque Français produit en moyenne **582 kg de déchets ménagers par an**, dont environ la moitié finit encore dans les ordures ménagères.

Réduire les déchets non recyclables permet de limiter la pollution des sols et des eaux, l'incinération et les émissions de gaz à effet de serre. 🌿
"""),
        ]
    )

    static let bestPractices = GuideEntry(
        id: "best", title: "Bonnes pratiques", subtitle: "Réduire, réutiliser, recycler",
        icon: "leaf.fill", color: .teal, wasteType: nil,
        sections: [
            GuideSection(title: "Réduire ses déchets", icon: "arrow.down.circle.fill", style: .tips, items: [
                GuideItem(icon: "cart.fill.badge.minus", text: "Privilégiez les produits avec moins d'emballages ou rechargeables."),
                GuideItem(icon: "bag.circle", text: "Utilisez des sacs réutilisables pour vos courses."),
                GuideItem(icon: "shippingbox.fill", text: "Favorisez l'achat en vrac quand c'est possible."),
                GuideItem(icon: "fork.knife", text: "Évitez les produits jetables (vaisselle, lingettes…)."),
            ]),
            GuideSection(title: "Réutiliser", icon: "arrow.triangle.2.circlepath.circle.fill", style: .accepted, items: [
                GuideItem(icon: "tshirt.fill", text: "Donnez une seconde vie aux vêtements en les donnant ou en les réparant."),
                GuideItem(icon: "gift.fill", text: "Réutilisez sacs, emballages et boîtes pour ranger ou emballer des cadeaux."),
                GuideItem(icon: "wrench.and.screwdriver.fill", text: "Réparez vos objets au lieu de les jeter."),
                GuideItem(icon: "book.fill", text: "Privilégiez l'occasion ou l'emprunt (livres, équipements)."),
            ]),
            GuideSection(title: "Compostage", icon: "leaf.arrow.circlepath", style: .tips, items: [
                GuideItem(icon: "leaf.fill", text: "Compostez épluchures, marc de café, coquilles d'œufs, restes de fruits et légumes."),
                GuideItem(icon: "drop.fill", text: "Évitez viande, poisson et produits gras dans le compost."),
                GuideItem(icon: "house.fill", text: "Un composteur individuel ou collectif réduit fortement vos déchets organiques."),
            ]),
            GuideSection(title: "Impact positif du tri", icon: "globe.europe.africa.fill", style: .info, body: """
En réduisant, réutilisant et recyclant, vous contribuez à :
• Réduire la quantité de déchets produits
• Préserver les ressources naturelles et la biodiversité
• Diminuer les émissions de gaz à effet de serre
• Améliorer la qualité de l'air, de l'eau et des sols 🌿
"""),
        ]
    )
}
