//
//  HouseholdInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 10/06/2025.
//

import SwiftUI

struct HouseholdInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                acceptedWasteSection

                rejectedWasteSection

                bestPracticesSection
                
                impactSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Ordures ménagères")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "trash.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Ordures ménagères")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Gérer efficacement les déchets non recyclables")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var acceptedWasteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("✅ Ce que vous pouvez jeter", systemImage: "checkmark.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "takeoutbag.and.cup.and.straw.fill", text: "Déchets alimentaires non compostés (restes de viande, poisson, produits laitiers...)")
                itemRow(icon: "sparkles.rectangle.stack.fill", text: "Emballages sales ou gras (cartons de pizza très souillés)")
                itemRow(icon: "tissue.fill", text: "Papiers et mouchoirs sales, couches, protections hygiéniques")
                itemRow(icon: "trash.slash.fill", text: "Petits déchets non recyclables (polystyrène, barquettes souillées, films alimentaires)")
                itemRow(icon: "shippingbox.and.arrow.backward.fill", text: "Petits objets en plastique cassés non recyclables")
            }
            .padding(.leading, 10)
        }
    }

    private var rejectedWasteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("❌ À ne pas déposer", systemImage: "xmark.octagon.fill")
                .font(.title2.bold())
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "battery.100.bolt", text: "Déchets dangereux (piles, batteries, produits chimiques)")
                itemRow(icon: "sofa.fill", text: "Déchets encombrants (meubles, électroménagers)")
                itemRow(icon: "paintbrush.fill", text: "Déchets toxiques (peintures, solvants, huiles moteur)")
                itemRow(icon: "leaf.arrow.circlepath", text: "Déchets verts (branchages, herbe, feuilles) destinés au compostage ou déchetterie")
                itemRow(icon: "lightbulb.fill", text: "Ampoules, néons et déchets électriques ou électroniques")
            }
            .padding(.leading, 10)
        }
    }

    private var bestPracticesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("♻️ Conseils pratiques", systemImage: "leaf.fill")
                .font(.title2.bold())
                .foregroundColor(.teal)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "trash.circle", text: "Ne mélangez jamais les déchets dangereux ou électroniques avec les ordures ménagères.")
                itemRow(icon: "drop.circle", text: "Égouttez bien les restes alimentaires avant de les jeter.")
                itemRow(icon: "bag.circle", text: "Utilisez des sacs poubelles solides et bien fermés pour éviter les fuites et odeurs.")
                itemRow(icon: "arrow.triangle.2.circlepath.circle", text: "Réduisez la quantité de déchets en triant un maximum de matières recyclables.")
            }
            .padding(.leading, 10)
        }
    }

    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("🌍 Impact des ordures ménagères", systemImage: "globe.europe.africa.fill")
                .font(.title2.bold())
                .foregroundColor(.blue)

            Text("""
Chaque Français produit en moyenne **582 kg de déchets ménagers par an**, dont environ 50% finissent encore dans les ordures ménagères.

Réduire les déchets non recyclables est essentiel pour :
• Limiter la pollution des sols et des eaux
• Réduire l'incinération et les émissions de gaz à effet de serre associées
• Préserver les ressources naturelles en augmentant le tri sélectif

Votre participation active au tri sélectif et à la réduction des déchets est un geste concret pour l'environnement. 🌿
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
