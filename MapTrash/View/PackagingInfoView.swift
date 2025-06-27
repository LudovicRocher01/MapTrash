//
//  PackagingInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 10/06/2025.
//

import SwiftUI

struct PackagingInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                acceptedPackagingSection

                rejectedPackagingSection

                bestPracticesSection
                
                didYouKnowSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tri des emballages")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "bag.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.yellow)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Emballages ménagers")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Recycler facilement vos emballages")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var acceptedPackagingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Emballages à déposer", systemImage: "checkmark.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "cube.box.fill", text: "Cartons et briques alimentaires (lait, jus, soupe)")
                itemRow(icon: "square.fill", text: "Boîtes métalliques (conserves, canettes, aérosols vidés)")
                itemRow(icon: "bag.fill", text: "Sacs plastiques, emballages plastiques souples")
                itemRow(icon: "takeoutbag.and.cup.and.straw.fill", text: "Barquettes, pots et bouteilles en plastique")
                itemRow(icon: "newspaper.fill", text: "Film plastique, opercules")
            }
            .padding(.leading, 10)
        }
    }

    private var rejectedPackagingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("À ne pas déposer", systemImage: "xmark.octagon.fill")
                .font(.title2.bold())
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "trash.slash.fill", text: "Déchets alimentaires")
                itemRow(icon: "paintpalette.fill", text: "Emballages souillés par des produits toxiques (peinture, solvants...)")
                itemRow(icon: "sparkles.rectangle.stack.fill", text: "Polystyrène expansé (emballages de protection, plateaux repas)")
                itemRow(icon: "battery.100", text: "Déchets électroniques, piles, batteries")
            }
            .padding(.leading, 10)
        }
    }

    private var bestPracticesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Conseils pratiques", systemImage: "leaf.fill")
                .font(.title2.bold())
                .foregroundColor(.teal)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "drop.circle", text: "Videz complètement les emballages avant de les jeter.")
                itemRow(icon: "trash.circle", text: "Ne lavez pas les emballages, mais évitez qu'ils soient trop souillés.")
                itemRow(icon: "arrow.triangle.2.circlepath", text: "Ne mettez pas les emballages dans des sacs fermés (déposez-les en vrac).")
                itemRow(icon: "exclamationmark.triangle", text: "Compactez légèrement les emballages pour optimiser la collecte.")
            }
            .padding(.leading, 10)
        }
    }

    private var didYouKnowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Le saviez-vous ?", systemImage: "globe.europe.africa.fill")
                .font(.title2.bold())
                .foregroundColor(.blue)

            Text("""
En France, environ **5 millions de tonnes** d'emballages ménagers sont recyclées chaque année. Recycler vos emballages permet :
• D’économiser des matières premières précieuses (pétrole, bois, minerais...)
• De diminuer la consommation énergétique (jusqu’à **95%** pour l’aluminium !)
• De limiter considérablement les émissions de gaz à effet de serre

Chaque geste compte pour préserver notre planète et nos ressources naturelles. 🌿
""")
            .padding(.leading, 10)
            .foregroundColor(.secondary)
        }
    }

    private func itemRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 25)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}
