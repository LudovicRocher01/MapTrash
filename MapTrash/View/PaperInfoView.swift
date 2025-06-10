//
//  PaperInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 10/06/2025.
//

import SwiftUI

struct PaperInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                acceptedPaperSection

                rejectedPaperSection

                bestPracticesSection
                
                impactSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tri du papier")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "newspaper.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Tri du papier")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Recycler efficacement le papier")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var acceptedPaperSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("✅ Papiers à recycler", systemImage: "checkmark.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "newspaper", text: "Journaux, magazines, prospectus, publicités papier")
                itemRow(icon: "doc.text.fill", text: "Feuilles de papier, courriers, enveloppes (y compris avec fenêtre)")
                itemRow(icon: "book.fill", text: "Cahiers, blocs-notes, livres sans couverture rigide")
                itemRow(icon: "envelope.fill", text: "Catalogues, annuaires, guides papier")
                itemRow(icon: "doc.on.clipboard.fill", text: "Impressions, documents administratifs sans données sensibles")
            }
            .padding(.leading, 10)
        }
    }

    private var rejectedPaperSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("❌ À ne pas déposer", systemImage: "xmark.octagon.fill")
                .font(.title2.bold())
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "carton.fill", text: "Cartons souillés ou gras (emballages alimentaires très sales)")
                itemRow(icon: "sparkles.rectangle.stack.fill", text: "Papier absorbant (essuie-tout, mouchoirs, lingettes)")
                itemRow(icon: "photo.fill", text: "Photos, papiers plastifiés, papier cadeau métallisé")
                itemRow(icon: "magazine.fill", text: "Couvertures plastifiées ou rigides de livres et cahiers")
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
                itemRow(icon: "trash.slash.circle", text: "Ne déchirez pas les enveloppes avec fenêtres plastifiées (elles sont recyclables !).")
                itemRow(icon: "doc.circle", text: "Évitez de froisser ou de déchirer excessivement les papiers pour faciliter le tri automatique.")
                itemRow(icon: "drop.circle", text: "Évitez les papiers souillés ou humides, privilégiez la poubelle classique dans ces cas-là.")
                itemRow(icon: "shield.lefthalf.filled", text: "Détruisez les papiers confidentiels avant recyclage, idéalement avec un broyeur papier.")
            }
            .padding(.leading, 10)
        }
    }

    private var impactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("🌍 Le saviez-vous ?", systemImage: "globe.europe.africa.fill")
                .font(.title2.bold())
                .foregroundColor(.blue)

            Text("""
Chaque tonne de papier recyclée permet de sauver :
• Jusqu'à **17 arbres adultes**
• Plus de **20 000 litres d'eau**
• Environ **2,5 tonnes de CO₂**

Le recyclage du papier nécessite **60% moins d'énergie** que sa production à partir de bois vierge. En France, 58% des papiers sont recyclés, mais ce chiffre peut encore progresser grâce à vos efforts quotidiens. 🌿
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
