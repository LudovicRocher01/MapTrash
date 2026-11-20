//
//  Container.swift
//  MapTrash
//
//  Conteneur d'apport volontaire issu du jeu de données de la Métropole Nice Côte d'Azur.
//

import Foundation
import CoreLocation

struct Container: Identifiable, Hashable, Sendable {
    /// Identifiant NCA (stable entre deux lancements → utilisé pour les favoris).
    let id: String
    let type: WasteType
    let latitude: Double
    let longitude: Double
    let address: String
    let commune: String
    let kind: String?
    let collectionDay: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }

    /// Adresse en casse lisible : « BD ARMEE DES ALPES » → « Bd Armee des Alpes ».
    var displayAddress: String { address.prettified }

    /// Nature du conteneur en clair.
    var kindLabel: String? {
        switch kind?.uppercased() {
        case "AERIEN": "Aérien"
        case "ENTERRE": "Enterré"
        case "SEMI ENTERRE": "Semi-enterré"
        case "ASCENSEUR": "À ascenseur"
        default: nil
        }
    }
}

// MARK: - Décodage GeoJSON

private struct FeatureCollection: Decodable {
    let features: [Feature]

    struct Feature: Decodable {
        let geometry: Geometry
        let properties: Properties
    }

    struct Geometry: Decodable {
        let coordinates: [Double]
    }

    struct Properties: Decodable {
        let conteneur: String
        let adresse: String?
        let commune: String?
        let idNCA: String?
        let type: String?
        let jour: String?

        enum CodingKeys: String, CodingKey {
            case conteneur = "CONTENEUR"
            case adresse = "ADRESSE"
            case commune = "COMMUNE"
            case idNCA = "ID_NCA"
            case type = "TYPE"
            case jour = "JOUR"
        }
    }
}

enum ContainerRepository {
    /// Charge et convertit `containers.json` (à appeler hors du thread principal).
    static func loadBundled() -> [Container] {
        guard let url = Bundle.main.url(forResource: "containers", withExtension: "json"),
              let data = try? Data(contentsOf: url, options: .mappedIfSafe),
              let collection = try? JSONDecoder().decode(FeatureCollection.self, from: data)
        else {
            assertionFailure("containers.json introuvable ou invalide")
            return []
        }

        var seen = Set<String>()
        return collection.features.enumerated().compactMap { index, feature in
            let p = feature.properties
            guard feature.geometry.coordinates.count == 2,
                  let type = WasteType(rawValue: p.conteneur.uppercased())
            else { return nil }

            let lon = feature.geometry.coordinates[0]
            let lat = feature.geometry.coordinates[1]
            guard CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: lat, longitude: lon)) else { return nil }

            var id = p.idNCA ?? "idx-\(index)"
            if !seen.insert(id).inserted { id += "-\(index)" }

            let day = p.jour.flatMap { $0 == "Inconnu" || $0.isEmpty ? nil : $0 }

            return Container(
                id: id,
                type: type,
                latitude: lat,
                longitude: lon,
                address: p.adresse ?? "Adresse inconnue",
                commune: p.commune ?? "Métropole Nice Côte d'Azur",
                kind: p.type,
                collectionDay: day
            )
        }
    }

    /// Le conteneur le plus proche d'un type donné.
    static func nearest(_ type: WasteType, in containers: [Container], from location: CLLocation) -> Container? {
        containers
            .lazy
            .filter { $0.type == type }
            .min { $0.location.distance(from: location) < $1.location.distance(from: location) }
    }
}

// MARK: - Formatage

extension String {
    /// Met en forme une adresse en majuscules (« RUE DE FRANCE / BD GAMBETTA »).
    var prettified: String {
        let lowerWords: Set<String> = ["de", "du", "des", "la", "le", "les", "l", "d", "et", "au", "aux", "a", "en", "sur", "face", "angle", "dans"]
        let lowered = self.lowercased()
        var result = ""
        var word = ""
        var isFirstWord = true

        func flush() {
            guard !word.isEmpty else { return }
            if !isFirstWord, lowerWords.contains(word) {
                result += word
            } else {
                result += word.prefix(1).uppercased() + word.dropFirst()
            }
            isFirstWord = false
            word = ""
        }

        for ch in lowered {
            if ch.isLetter || ch.isNumber {
                word.append(ch)
            } else {
                flush()
                result.append(ch)
            }
        }
        flush()
        return result
    }
}

enum DistanceFormatter {
    static func distance(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            let rounded = meters < 100 ? (meters / 5).rounded() * 5 : (meters / 10).rounded() * 10
            return "\(Int(rounded)) m"
        }
        let km = meters / 1000
        return km < 10 ? String(format: "%.1f km", km).replacingOccurrences(of: ".", with: ",") : "\(Int(km.rounded())) km"
    }

    /// Estimation à pied (~ 4,8 km/h, avec facteur de détour 1,25).
    static func walkingTime(_ meters: CLLocationDistance) -> String {
        let minutes = max(1, Int((meters * 1.25 / 80).rounded()))
        return duration(minutes: minutes)
    }

    static func duration(seconds: TimeInterval) -> String {
        duration(minutes: max(1, Int((seconds / 60).rounded())))
    }

    static func duration(minutes: Int) -> String {
        if minutes < 60 { return "\(minutes) min" }
        let h = minutes / 60, m = minutes % 60
        return m == 0 ? "\(h) h" : "\(h) h \(String(format: "%02d", m))"
    }
}
