//
//  Glass.swift
//  MapTrash
//
//  Liquid Glass sur iOS 26, matériau classique sur iOS 17/18.
//

import SwiftUI

extension View {
    /// Bouton rond flottant au-dessus de la carte.
    @ViewBuilder
    func glassCircle() -> some View {
        if #available(iOS 26, *) {
            self.frame(width: 48, height: 48)
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            self.frame(width: 48, height: 48)
                .background(.regularMaterial, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
    }

    /// Carte / panneau arrondi.
    @ViewBuilder
    func glassPanel(cornerRadius: CGFloat = 22) -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.regularMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
        }
    }

    /// Fond de tuile dans la feuille (pas de verre sur verre).
    func tileBackground(cornerRadius: CGFloat = 16) -> some View {
        background(Color(.secondarySystemGroupedBackground).opacity(0.9),
                   in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Bouton d'action principal (proéminent).
    @ViewBuilder
    func prominentButtonStyle(tint: Color = .accentColor) -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glassProminent).tint(tint)
        } else {
            self.buttonStyle(.borderedProminent).tint(tint)
        }
    }

    @ViewBuilder
    func secondaryButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}

/// Regroupe des boutons de verre pour qu'ils fusionnent visuellement (iOS 26).
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content }
        } else {
            content
        }
    }
}

/// Pastille ronde colorée avec icône (types de déchets, destinations).
struct IconBadge: View {
    let icon: String
    let color: Color
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: Circle())
            .accessibilityHidden(true)
    }
}
