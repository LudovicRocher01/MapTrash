//
//  SortingDictionary.swift
//  MapTrash
//
//  « Où jeter… ? » : dictionnaire hors-ligne objet → destination.
//

import SwiftUI

enum Destination: Hashable {
    case container(WasteType)
    case recyclingCenter
    case pharmacy
    case shop          // point de collecte en magasin (piles, ampoules, cartouches…)
    case compost
    case reuse         // don / ressourcerie

    var title: String {
        switch self {
        case .container(let type): "Conteneur \(type.fullName.lowercased())"
        case .recyclingCenter: "Déchetterie"
        case .pharmacy: "Pharmacie"
        case .shop: "Point de collecte en magasin"
        case .compost: "Compost"
        case .reuse: "Don ou ressourcerie"
        }
    }

    var icon: String {
        switch self {
        case .container(let type): type.icon
        case .recyclingCenter: "building.2.fill"
        case .pharmacy: "cross.case.fill"
        case .shop: "storefront.fill"
        case .compost: "leaf.fill"
        case .reuse: "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .container(let type): type.color
        case .recyclingCenter: .brown
        case .pharmacy: .green
        case .shop: .purple
        case .compost: .mint
        case .reuse: .pink
        }
    }
}

struct SortingItem: Identifiable, Hashable {
    let name: String
    let keywords: [String]
    let destination: Destination
    let advice: String
    /// Destination de repli (ex. carton de pizza souillé → ordures).
    var alternative: Destination? = nil

    var id: String { name }

    fileprivate var searchKeys: [String] {
        ([name] + keywords).map(\.searchNormalized)
    }
}

enum SortingDictionary {
    static let popular: [String] = ["Pile", "Pot de yaourt", "Ampoule", "Carton de pizza", "Médicaments", "Vêtements", "Bouteille d'huile", "Capsule de café"]

    static func search(_ query: String) -> [SortingItem] {
        let q = query.searchNormalized
        guard !q.isEmpty else { return [] }
        let tokens = q.split(separator: " ").map(String.init)

        return items
            .compactMap { item -> (SortingItem, Int)? in
                let keys = item.searchKeys
                if keys.contains(q) { return (item, 0) }
                if keys.contains(where: { $0.hasPrefix(q) }) { return (item, 1) }
                if tokens.allSatisfy({ t in keys.contains { $0.contains(t) } }) { return (item, 2) }
                return nil
            }
            .sorted { $0.1 == $1.1 ? $0.0.name < $1.0.name : $0.1 < $1.1 }
            .map(\.0)
    }

    static func item(named name: String) -> SortingItem? {
        items.first { $0.name == name }
    }

    static let items: [SortingItem] = [
        // MARK: Verre
        SortingItem(name: "Bouteille en verre", keywords: ["bouteille vin", "bouteille biere", "verre", "champagne", "rosé"], destination: .container(.glass), advice: "Videz-la et retirez le bouchon. Pas besoin de la laver."),
        SortingItem(name: "Pot de confiture", keywords: ["bocal", "pot en verre", "pot de miel", "pot de sauce", "cornichons"], destination: .container(.glass), advice: "Retirez le couvercle métallique et jetez-le dans les emballages."),
        SortingItem(name: "Flacon de parfum", keywords: ["parfum", "flacon verre", "huile essentielle"], destination: .container(.glass), advice: "Retirez le bouchon et le vaporisateur si possible."),
        SortingItem(name: "Verre à boire cassé", keywords: ["verre cassé", "vaisselle", "assiette", "porcelaine", "tasse", "mug", "céramique", "pyrex", "plat en verre"], destination: .container(.household), advice: "La vaisselle ne fond pas à la même température que le verre d'emballage : elle perturbe le recyclage. Emballez-la pour éviter les coupures."),
        SortingItem(name: "Miroir", keywords: ["vitre", "fenêtre", "verre plat"], destination: .recyclingCenter, advice: "Les miroirs et vitres vont en déchetterie, jamais dans le conteneur à verre."),

        // MARK: Emballages
        SortingItem(name: "Pot de yaourt", keywords: ["yaourt", "yogourt", "pot plastique", "pot de crème", "dessert"], destination: .container(.packaging), advice: "Videz-le bien, inutile de le laver. L'opercule va aussi dans les emballages."),
        SortingItem(name: "Bouteille en plastique", keywords: ["bouteille d'eau", "bouteille eau", "plastique", "soda", "flacon plastique", "bouteille de lait"], destination: .container(.packaging), advice: "Videz-la, laissez le bouchon vissé."),
        SortingItem(name: "Canette", keywords: ["cannette", "boîte de soda", "aluminium", "bière canette"], destination: .container(.packaging), advice: "Videz-la, ne l'écrasez pas complètement."),
        SortingItem(name: "Boîte de conserve", keywords: ["conserve", "boîte métal", "boîte de thon", "boîte de raviolis"], destination: .container(.packaging), advice: "Bien vidée, sans la laver."),
        SortingItem(name: "Brique de lait", keywords: ["brique", "tetra pak", "brique de jus", "brique de soupe", "lait"], destination: .container(.packaging), advice: "Videz-la, laissez le bouchon."),
        SortingItem(name: "Carton d'emballage", keywords: ["carton", "boîte en carton", "colis", "carton amazon", "boîte de céréales", "suremballage"], destination: .container(.packaging), advice: "Aplatissez-le. Les très grands cartons vont en déchetterie."),
        SortingItem(name: "Carton de pizza", keywords: ["pizza", "boîte à pizza"], destination: .container(.packaging), advice: "Propre ou peu taché : emballages. Très gras ou avec des restes : ordures ménagères.", alternative: .container(.household)),
        SortingItem(name: "Film plastique", keywords: ["film", "cellophane", "emballage souple", "sachet", "sachet de chips", "sachet de bonbons", "blister"], destination: .container(.packaging), advice: "Tous les emballages plastiques se trient, même les petits."),
        SortingItem(name: "Sac plastique", keywords: ["sac de caisse", "sac"], destination: .container(.packaging), advice: "Déposez-le vide, ne mettez pas vos emballages dedans."),
        SortingItem(name: "Barquette", keywords: ["barquette plastique", "barquette alu", "barquette viande", "barquette fruits"], destination: .container(.packaging), advice: "Bien vidée. Si elle est très sale : ordures ménagères."),
        SortingItem(name: "Aérosol", keywords: ["bombe", "déodorant", "laque", "mousse à raser", "spray"], destination: .container(.packaging), advice: "Uniquement s'il est complètement vide. Les aérosols de produits toxiques (peinture, insecticide) vont en déchetterie.", alternative: .recyclingCenter),
        SortingItem(name: "Capsule de café", keywords: ["dosette", "nespresso", "capsule alu", "café"], destination: .container(.packaging), advice: "Les capsules en aluminium vont dans les emballages. Les dosettes papier et le marc vont au compost.", alternative: .compost),
        SortingItem(name: "Bouchon", keywords: ["couvercle", "capsule de bière", "bouchon plastique", "capsule métal"], destination: .container(.packaging), advice: "Bouchons et couvercles en plastique ou en métal vont dans les emballages. Les bouchons en liège peuvent être donnés à des associations."),
        SortingItem(name: "Tube de dentifrice", keywords: ["dentifrice", "tube", "tube de crème"], destination: .container(.packaging), advice: "Videz-le au maximum et laissez le bouchon."),
        SortingItem(name: "Flacon de shampoing", keywords: ["shampoing", "gel douche", "flacon salle de bain", "produit vaisselle", "lessive"], destination: .container(.packaging), advice: "Vide, avec son bouchon."),
        SortingItem(name: "Papier aluminium", keywords: ["alu", "papier alu", "aluminium ménager"], destination: .container(.packaging), advice: "Faites une boule : les petits morceaux d'aluminium se recyclent mieux ainsi."),
        SortingItem(name: "Gobelet en carton", keywords: ["gobelet", "gobelet café", "gobelet plastique"], destination: .container(.packaging), advice: "Videz-le."),
        SortingItem(name: "Bouteille d'huile", keywords: ["huile de cuisine bouteille", "bouteille vinaigre"], destination: .container(.packaging), advice: "La bouteille vide va dans les emballages. L'huile usagée, elle, va en déchetterie.", alternative: .recyclingCenter),
        SortingItem(name: "Polystyrène", keywords: ["frigolite", "calage", "barquette polystyrène"], destination: .container(.household), advice: "Les petites barquettes vont aux ordures. Les gros blocs de calage vont en déchetterie.", alternative: .recyclingCenter),

        // MARK: Papier
        SortingItem(name: "Journal", keywords: ["journaux", "magazine", "revue", "prospectus", "publicité", "catalogue"], destination: .container(.paper), advice: "Retirez le film plastique."),
        SortingItem(name: "Enveloppe", keywords: ["enveloppe à fenêtre", "courrier", "lettre"], destination: .container(.paper), advice: "Même avec une fenêtre plastique."),
        SortingItem(name: "Feuille de papier", keywords: ["papier", "feuille", "impression", "photocopie", "ticket de caisse papier"], destination: .container(.paper), advice: "Ne la froissez pas. Les tickets de caisse thermiques vont plutôt aux ordures.", alternative: .container(.household)),
        SortingItem(name: "Cahier", keywords: ["bloc-notes", "carnet", "agenda"], destination: .container(.paper), advice: "Retirez la couverture plastique et les spirales."),
        SortingItem(name: "Livre", keywords: ["livres", "bouquin", "roman", "bd"], destination: .container(.paper), advice: "En bon état, donnez-le (boîte à livres, association). Sinon : conteneur papier, sans couverture rigide.", alternative: .reuse),
        SortingItem(name: "Annuaire", keywords: ["bottin", "pages jaunes"], destination: .container(.paper), advice: "Tel quel."),

        // MARK: Textile
        SortingItem(name: "Vêtements", keywords: ["vêtement", "habits", "t-shirt", "pantalon", "pull", "robe", "jean", "manteau"], destination: .container(.textile), advice: "Propres et secs, dans un sac fermé, même usés ou troués."),
        SortingItem(name: "Chaussures", keywords: ["baskets", "chaussure", "bottes", "sandales"], destination: .container(.textile), advice: "Attachées par paire."),
        SortingItem(name: "Linge de maison", keywords: ["draps", "serviette", "rideaux", "nappe", "torchon", "couette"], destination: .container(.textile), advice: "Propre et sec, dans un sac fermé."),
        SortingItem(name: "Sac à main", keywords: ["maroquinerie", "ceinture", "portefeuille", "sac à dos"], destination: .container(.textile), advice: "La petite maroquinerie est acceptée."),
        SortingItem(name: "Peluche", keywords: ["doudou", "nounours"], destination: .container(.textile), advice: "Propre et sèche."),

        // MARK: Ordures ménagères
        SortingItem(name: "Mouchoir", keywords: ["mouchoirs", "essuie-tout", "sopalin", "serviette en papier", "lingette"], destination: .container(.household), advice: "Les papiers souillés ne se recyclent pas."),
        SortingItem(name: "Couche", keywords: ["couches", "protection hygiénique", "serviette hygiénique", "tampon", "coton"], destination: .container(.household), advice: "Dans un sac fermé."),
        SortingItem(name: "Restes de repas", keywords: ["nourriture", "restes", "viande", "poisson", "os", "fromage"], destination: .container(.household), advice: "Les épluchures de fruits et légumes peuvent aller au compost.", alternative: .compost),
        SortingItem(name: "Mégot", keywords: ["cigarette", "mégots"], destination: .container(.household), advice: "Jamais par terre : un mégot pollue jusqu'à 500 litres d'eau."),
        SortingItem(name: "Brosse à dents", keywords: ["rasoir jetable", "brosse"], destination: .container(.household), advice: "Ce ne sont pas des emballages."),
        SortingItem(name: "Litière", keywords: ["litière chat", "sable chat"], destination: .container(.household), advice: "Dans un sac bien fermé."),
        SortingItem(name: "Jouet en plastique", keywords: ["jouet", "objet plastique", "cintre", "seau"], destination: .container(.household), advice: "Seuls les emballages vont dans le bac emballages. Un jouet en bon état peut être donné.", alternative: .reuse),
        SortingItem(name: "Chewing-gum", keywords: ["gomme", "chewing gum"], destination: .container(.household), advice: "Emballé dans un papier."),

        // MARK: Compost
        SortingItem(name: "Épluchures", keywords: ["épluchure", "pelures", "fruits", "légumes", "coquille d'oeuf", "coquilles d'œufs", "trognon"], destination: .compost, advice: "Au compost si vous en avez un, sinon aux ordures ménagères.", alternative: .container(.household)),
        SortingItem(name: "Marc de café", keywords: ["marc", "filtre à café", "sachet de thé", "thé"], destination: .compost, advice: "Excellent pour le compost.", alternative: .container(.household)),

        // MARK: Déchetterie
        SortingItem(name: "Huile de friture", keywords: ["huile usagée", "huile de cuisson", "friteuse"], destination: .recyclingCenter, advice: "Jamais dans l'évier ! Rapportez-la dans une bouteille fermée en déchetterie."),
        SortingItem(name: "Peinture", keywords: ["pot de peinture", "vernis", "solvant", "white spirit", "colle", "produit chimique", "décapant"], destination: .recyclingCenter, advice: "Produit dangereux : dans son emballage d'origine, en déchetterie."),
        SortingItem(name: "Électroménager", keywords: ["frigo", "réfrigérateur", "lave-linge", "machine à laver", "micro-ondes", "four", "aspirateur", "grille-pain", "bouilloire", "sèche-cheveux"], destination: .recyclingCenter, advice: "En déchetterie, ou repris gratuitement par le magasin lors d'un achat neuf (« un pour un »).", alternative: .shop),
        SortingItem(name: "Appareil électronique", keywords: ["téléphone", "smartphone", "ordinateur", "télévision", "tv", "écran", "câble", "chargeur", "console", "tablette", "imprimante"], destination: .recyclingCenter, advice: "Les petits appareils peuvent aussi être déposés dans les bacs dédiés en magasin.", alternative: .shop),
        SortingItem(name: "Meuble", keywords: ["meubles", "canapé", "chaise", "table", "armoire", "matelas", "sommier", "encombrant"], destination: .recyclingCenter, advice: "En déchetterie, ou via le service des encombrants de votre commune. En bon état : donnez-le !", alternative: .reuse),
        SortingItem(name: "Déchets verts", keywords: ["branches", "branchages", "herbe", "tonte", "feuilles mortes", "taille de haie", "sapin"], destination: .recyclingCenter, advice: "En déchetterie. Le brûlage est interdit."),
        SortingItem(name: "Gravats", keywords: ["gravats", "ciment", "carrelage", "plâtre", "briques", "pierres", "travaux"], destination: .recyclingCenter, advice: "En petite quantité, en déchetterie."),
        SortingItem(name: "Pneus", keywords: ["pneu", "jante"], destination: .recyclingCenter, advice: "Repris par les garages, ou en déchetterie selon le site."),
        SortingItem(name: "Batterie de voiture", keywords: ["batterie auto", "batterie moto"], destination: .recyclingCenter, advice: "Déchet dangereux : déchetterie ou garage."),
        SortingItem(name: "Huile de vidange", keywords: ["huile moteur", "vidange"], destination: .recyclingCenter, advice: "En déchetterie, dans un bidon fermé."),
        SortingItem(name: "Bois", keywords: ["planche", "palette", "bois"], destination: .recyclingCenter, advice: "En déchetterie, benne bois."),
        SortingItem(name: "Ferraille", keywords: ["métal", "vélo", "casserole", "poêle", "outil"], destination: .recyclingCenter, advice: "En déchetterie, benne métaux. Un vélo réparable peut être donné.", alternative: .reuse),
        SortingItem(name: "Bouteille de gaz", keywords: ["gaz", "butane", "propane", "extincteur"], destination: .shop, advice: "Rapportez-la à un distributeur de la même marque. Jamais en déchetterie classique."),

        // MARK: Magasin / pharmacie
        SortingItem(name: "Pile", keywords: ["piles", "batterie", "accumulateur", "pile bouton"], destination: .shop, advice: "Bacs de collecte à l'entrée des supermarchés et magasins de bricolage. Aussi acceptées en déchetterie.", alternative: .recyclingCenter),
        SortingItem(name: "Ampoule", keywords: ["ampoules", "led", "néon", "tube fluorescent", "ampoule basse consommation"], destination: .shop, advice: "Dans les bacs en magasin (bricolage, supermarché) ou en déchetterie. Les ampoules à filament vont aux ordures.", alternative: .recyclingCenter),
        SortingItem(name: "Cartouche d'encre", keywords: ["cartouche", "toner", "encre"], destination: .shop, advice: "Rapportez-la en magasin d'informatique ou de fournitures de bureau."),
        SortingItem(name: "Médicaments", keywords: ["médicament", "pilules", "comprimés", "sirop", "boîte de médicaments"], destination: .pharmacy, advice: "Rapportez les médicaments périmés ou non utilisés en pharmacie. Les boîtes en carton et notices vont dans le papier."),
        SortingItem(name: "Seringue", keywords: ["aiguille", "lancette", "stylo insuline"], destination: .pharmacy, advice: "Dans une boîte jaune DASRI, à rapporter en pharmacie."),
        SortingItem(name: "Radiographie", keywords: ["radio", "radiographie"], destination: .pharmacy, advice: "Certaines pharmacies les collectent (sels d'argent recyclables)."),
    ]
}

extension String {
    /// Minuscules, sans accents ni apostrophes typographiques.
    var searchNormalized: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr_FR"))
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "œ", with: "oe")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
