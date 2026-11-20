//
//  RecyclingCenter.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 13/08/2025.
//

import Foundation
import CoreLocation

struct RecyclingCenter: Decodable, Identifiable, Hashable {
    struct Coordinate: Decodable, Hashable {
        let latitude: Double
        let longitude: Double
    }

    /// Plage d'ouverture : jours ISO (1 = lundi … 7 = dimanche) et créneaux « HH:mm ».
    struct OpeningRule: Decodable, Hashable {
        let jours: [Int]
        let plages: [[String]]
    }

    let name: String
    let address: String
    let phone: String
    let hours: String
    let location: Coordinate
    let opening: [OpeningRule]

    var id: String { name }

    /// « Déchetterie - Nice Est » → « Nice Est ».
    var shortName: String {
        name.components(separatedBy: " - ").last ?? name
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var clLocation: CLLocation { CLLocation(latitude: location.latitude, longitude: location.longitude) }

    var phoneURL: URL? {
        URL(string: "tel:" + phone.filter { $0.isNumber || $0 == "+" })
    }

    enum CodingKeys: String, CodingKey {
        case name = "nom"
        case address = "adresse"
        case phone = "telephone"
        case hours = "horaires"
        case location
        case opening = "ouverture"
    }

    // MARK: Ouverture

    enum OpenState: Equatable {
        case open(until: String)
        case closed(nextOpening: String?)
    }

    /// État d'ouverture (hors jours fériés, non gérés).
    func openState(at date: Date = .now, calendar: Calendar = .current) -> OpenState {
        let isoDay = Self.isoWeekday(of: date, calendar: calendar)
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        let now = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)

        for (start, end) in slots(onISODay: isoDay) where now >= start && now < end {
            return .open(until: Self.format(end))
        }

        // Prochaine ouverture : plus tard aujourd'hui, puis les 7 jours suivants.
        if let next = slots(onISODay: isoDay).first(where: { $0.0 > now }) {
            return .closed(nextOpening: "aujourd'hui à \(Self.format(next.0))")
        }
        for offset in 1...7 {
            let day = (isoDay - 1 + offset) % 7 + 1
            if let first = slots(onISODay: day).first {
                let label = offset == 1 ? "demain" : Self.dayNames[day - 1]
                return .closed(nextOpening: "\(label) à \(Self.format(first.0))")
            }
        }
        return .closed(nextOpening: nil)
    }

    private func slots(onISODay day: Int) -> [(Int, Int)] {
        opening
            .filter { $0.jours.contains(day) }
            .flatMap { $0.plages }
            .compactMap { pair in
                guard pair.count == 2, let s = Self.minutes(pair[0]), let e = Self.minutes(pair[1]) else { return nil }
                return (s, e)
            }
            .sorted { $0.0 < $1.0 }
    }

    private static let dayNames = ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"]

    private static func isoWeekday(of date: Date, calendar: Calendar) -> Int {
        let weekday = calendar.component(.weekday, from: date) // 1 = dimanche
        return weekday == 1 ? 7 : weekday - 1
    }

    private static func minutes(_ hhmm: String) -> Int? {
        let parts = hhmm.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return parts[0] * 60 + parts[1]
    }

    private static func format(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return m == 0 ? "\(h)h" : "\(h)h\(String(format: "%02d", m))"
    }

    static func loadBundled() -> [RecyclingCenter] {
        guard let url = Bundle.main.url(forResource: "recyclingcenter", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return [] }
        do {
            return try JSONDecoder().decode([RecyclingCenter].self, from: data)
        } catch {
            assertionFailure("recyclingcenter.json invalide : \(error)")
            return []
        }
    }
}
