//
//  BestPracticesInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 10/06/2025.
//

import SwiftUI

struct BestPracticesInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                reduceWasteSection

                reuseSection

                recyclingTipsSection
                
                compostingSection
                
                globalImpactSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Bonnes pratiques")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "leaf.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.teal)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Bonnes pratiques")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Réduire, réutiliser, recycler")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var reduceWasteSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("📉 Réduire ses déchets", systemImage: "arrow.down.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "cart.fill.badge.minus", text: "Privilégiez les produits avec moins d'emballages ou rechargeables.")
                itemRow(icon: "bag.circle", text: "Utilisez des sacs réutilisables pour vos courses.")
                itemRow(icon: "shippingbox.fill", text: "Favorisez l’achat en vrac quand c’est possible.")
                itemRow(icon: "fork.knife", text: "Évitez les produits jetables (vaisselle, lingettes...).")
            }
            .padding(.leading, 10)
        }
    }

    private var reuseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("🔄 Réutiliser", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "tshirt.fill", text: "Donnez une seconde vie aux vêtements en les donnant ou réparant.")
                itemRow(icon: "gift.fill", text: "Réutilisez sacs, emballages, boîtes pour ranger ou emballer des cadeaux.")
                itemRow(icon: "wrench.and.screwdriver.fill", text: "Réparez vos objets au lieu de les jeter immédiatement.")
                itemRow(icon: "book.fill", text: "Privilégiez l'achat d’occasion ou l'emprunt (livres, équipements).")
            }
            .padding(.leading, 10)
        }
    }

    private var recyclingTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("♻️ Conseils de recyclage", systemImage: "trash.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "drop.circle", text: "Videz toujours les emballages avant recyclage (sans lavage intensif).")
                itemRow(icon: "doc.circle", text: "Ne déchirez pas excessivement les papiers pour faciliter le tri.")
                itemRow(icon: "trash.slash.circle", text: "Ne mettez jamais de sacs fermés dans les bacs de tri sélectif.")
                itemRow(icon: "bin.xmark.fill", text: "Respectez les consignes locales pour éviter les erreurs de tri.")
            }
            .padding(.leading, 10)
        }
    }

    private var compostingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("🌱 Compostage", systemImage: "leaf.arrow.circlepath")
                .font(.title2.bold())
                .foregroundColor(.brown)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "leaf.fill", text: "Compostez épluchures, marc de café, coquilles d'œufs, restes de fruits et légumes.")
                itemRow(icon: "drop.fill", text: "Évitez viande, poisson et produits gras dans le compost.")
                itemRow(icon: "house.fill", text: "Installez un composteur individuel ou collectif pour réduire vos déchets organiques.")
                itemRow(icon: "sparkles", text: "Le compost est idéal pour enrichir naturellement vos plantations et jardins.")
            }
            .padding(.leading, 10)
        }
    }

    private var globalImpactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("🌍 Impact positif du tri", systemImage: "globe.europe.africa.fill")
                .font(.title2.bold())
                .foregroundColor(.indigo)

            Text("""
En appliquant ces bonnes pratiques, vous contribuez à :
• La réduction significative de la quantité de déchets produits
• La préservation des ressources naturelles et la biodiversité
• La diminution des émissions de gaz à effet de serre liées au traitement des déchets
• L'amélioration de la qualité de l’air, de l'eau et des sols

Chaque geste compte : en réduisant, réutilisant et recyclant, vous participez activement à la préservation de notre planète pour les générations futures. 🌿
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

