//
//  TextileInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 10/06/2025.
//

import SwiftUI

struct TextileInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                acceptedTextilesSection

                rejectedTextilesSection

                bestPracticesSection
                
                didYouKnowSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tri du textile")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "tshirt.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Tri du textile")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Recycler les textiles efficacement")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var acceptedTextilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Textiles acceptés", systemImage: "checkmark.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "tshirt", text: "Vêtements (même usés ou déchirés)")
                itemRow(icon: "bed.double.fill", text: "Linge de maison (draps, rideaux, serviettes...)")
                itemRow(icon: "shoeprints.fill", text: "Chaussures (attachées par paires)")
                itemRow(icon: "bag.fill", text: "Petite maroquinerie (sacs, ceintures...)")
                itemRow(icon: "teddybear.fill", text: "Peluches")
            }
            .padding(.leading, 10)
        }
    }

    private var rejectedTextilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("À ne pas déposer", systemImage: "xmark.octagon.fill")
                .font(.title2.bold())
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "paintbrush.fill", text: "Textiles souillés (peinture, produits chimiques...)")
                itemRow(icon: "drop.fill", text: "Textiles humides ou moisis")
                itemRow(icon: "sofa.fill", text: "Articles encombrants (matelas, tapis, meubles rembourrés...)")
                itemRow(icon: "helm", text: "Accessoires rigides (casques, valises rigides)")
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
                itemRow(icon: "bag.circle", text: "Déposer les textiles propres et secs, même usés ou troués.")
                itemRow(icon: "link.circle", text: "Attacher les chaussures par paire (lacets ou élastique).")
                itemRow(icon: "shippingbox.fill", text: "Déposer dans des sacs fermés (idéalement réutilisables).")
                itemRow(icon: "hands.clap.fill", text: "Favoriser le don si les vêtements sont encore portables.")
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
Recycler les textiles permet chaque année en France de :
• Réduire considérablement l'impact environnemental de la mode
• Économiser de l'eau (environ **2 700 litres par t-shirt recyclé**)
• Réduire les émissions de gaz à effet de serre liées à la production textile

La filière textile crée également des emplois locaux dans les secteurs du tri et du recyclage. Votre geste compte pour la planète et l'économie solidaire 🌿.
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
