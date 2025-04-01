//
//  ContainerLoader.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 18/03/2025.
//

import Foundation
import CoreLocation

class ContainerLoader: ObservableObject {
    @Published var containers: [Container] = []
    @Published var selectedTypes: Set<String> = []

    init() {
        loadJSON()
    }

    func loadJSON() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: "containers", withExtension: "json") else {
                print("Fichier JSON introuvable")
                return
            }

            do {
                let data = try Data(contentsOf: url)
                let decodedData = try JSONDecoder().decode(ContainerData.self, from: data)

                let processedContainers = decodedData.features.compactMap { feature -> Container? in
                    guard feature.geometry.coordinates.count == 2 else { return nil }
                    
                    let coordinate = CLLocationCoordinate2D(
                        latitude: feature.geometry.coordinates[1],
                        longitude: feature.geometry.coordinates[0]
                    )

                    return CLLocationCoordinate2DIsValid(coordinate) ? Container(
                        coordinate: coordinate,
                        type: feature.properties.type
                    ) : nil
                }

                DispatchQueue.main.async {
                    self.containers = processedContainers
                }
            } catch {
                print("Erreur de décodage JSON : \(error)")
            }
        }
    }

    func toggleType(_ type: String) {
        if selectedTypes.contains(type) {
            selectedTypes.remove(type)
        } else {
            selectedTypes.insert(type)
        }
        objectWillChange.send()
    }
}
