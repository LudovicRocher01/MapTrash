//
//  WasteInfoView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 24/03/2025.
//

import Foundation
import SwiftUI

struct InfoTile: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
}

struct WasteInfoView: View {
    @Environment(\.presentationMode) var presentationMode

    let tiles = [
        InfoTile(title: "Verre", icon: "wineglass", color: .green),
        InfoTile(title: "Textile", icon: "tshirt", color: .blue),
        InfoTile(title: "Emballages", icon: "bag", color: .yellow),
        InfoTile(title: "Ordures", icon: "trash", color: .red),
        InfoTile(title: "Papier", icon: "newspaper", color: .orange),
        InfoTile(title: "Bonnes pratiques", icon: "leaf", color: .teal)
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(tiles) { tile in
                        NavigationLink(destination: destinationView(for: tile)) {
                            VStack {
                                Image(systemName: tile.icon)
                                    .font(.system(size: 40))
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 120)
                                    .background(tile.color)
                                    .cornerRadius(15)
                                    .shadow(radius: 5)

                                Text(tile.title)
                                    .foregroundColor(.primary)
                                    .font(.headline)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Guide du tri ♻️")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .imageScale(.large)
            })
        }
    }

    @ViewBuilder
    func destinationView(for tile: InfoTile) -> some View {
        switch tile.title {
        case "Verre":
            GlassInfoView()
        case "Textile":
            TextileInfoView()
        case "Emballages":
            PackagingInfoView()
        case "Ordures":
            HouseholdInfoView()
        case "Papier":
            PaperInfoView()
        case "Bonnes pratiques":
            BestPracticesInfoView()
        default:
            Text(tile.title)
                .font(.largeTitle)
                .padding()
        }
    }
}
