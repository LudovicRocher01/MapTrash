import SwiftUI

struct GlassInfoView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                headerSection
                
                acceptedGlassSection

                rejectedGlassSection

                bestPracticesSection
                
                didYouKnowSection
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Tri du verre")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "wineglass.fill")
                .foregroundColor(.white)
                .font(.largeTitle)
                .padding()
                .background(Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text("Tri du verre")
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Recycler facilement le verre")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var acceptedGlassSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ce que vous pouvez jeter", systemImage: "checkmark.circle.fill")
                .font(.title2.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "wineglass.fill", text: "Bouteilles en verre (vin, bière, soda, jus de fruit...)")
                itemRow(icon: "cup.and.saucer.fill", text: "Pots, bocaux alimentaires (confitures, sauces, miel...)")
                itemRow(icon: "flask.fill", text: "Flacons cosmétiques et pharmaceutiques (parfum, huile essentielle...)")
            }
            .padding(.leading, 10)
        }
    }

    private var rejectedGlassSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("À ne surtout pas déposer", systemImage: "xmark.octagon.fill")
                .font(.title2.bold())
                .foregroundColor(.red)

            VStack(alignment: .leading, spacing: 8) {
                itemRow(icon: "fork.knife.circle.fill", text: "Vaisselle en verre ou porcelaine (verres cassés, assiettes...)")
                itemRow(icon: "lightbulb.fill", text: "Ampoules, néons, tubes fluorescents")
                itemRow(icon: "mirror.side.left", text: "Vitres, miroirs, verre armé ou feuilleté")
                itemRow(icon: "drop.triangle.fill", text: "Contenants en plastique, métal ou carton")
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
                itemRow(icon: "drop.circle", text: "Bien vider les contenants, mais inutile de les laver.")
                itemRow(icon: "trash.circle", text: "Déposez le verre directement en vrac, sans sac plastique.")
                itemRow(icon: "arrow.triangle.2.circlepath", text: "Retirez bouchons et couvercles en métal ou plastique.")
                itemRow(icon: "exclamationmark.triangle", text: "Évitez absolument de mélanger avec d’autres matériaux.")
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
Recycler une tonne de verre permet de :
• Réduire la consommation énergétique d'environ **25%**
• Économiser environ **700 kg de sable**
• Éviter l'émission d'environ **500 kg de CO₂**

Le verre est recyclable à l'infini, sans perte de qualité ni de pureté. Chaque bouteille triée contribue directement à préserver notre planète. 🌱
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
