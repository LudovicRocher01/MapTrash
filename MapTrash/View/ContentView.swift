//
//  ContentView.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 18/03/2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var containerLoader = ContainerLoader()
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var showingInfo: Bool = false

    private let types: [String] = [
        "VERRE",
        "TEXTILE",
        "EMBALLAGES MENAGERS",
        "ORDURES MENAGERES",
        "PAPIER"
    ]
    
    private let typeNames: [String: String] = [
        "VERRE":    "Verre",
        "TEXTILE":  "Textile",
        "EMBALLAGES MENAGERS": "Emballages\nMénagèrs",
        "ORDURES MENAGERES":    "Ordures\nMénagères",
        "PAPIER":   "Papier"
    ]

    private let typeIcons: [String: String] = [
        "VERRE": "wineglass",
        "TEXTILE": "tshirt",
        "EMBALLAGES MENAGERS": "bag",
        "ORDURES MENAGERES": "trash",
        "PAPIER": "newspaper"
    ]
    private let typeColors: [String: Color] = [
        "VERRE": .green,
        "TEXTILE": .blue,
        "EMBALLAGES MENAGERS": .yellow,
        "ORDURES MENAGERES": .red,
        "PAPIER": .orange
    ]

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.7102, longitude: 7.2620),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var selectedContainer: Container?

    var filteredContainers: [Container] {
        containerLoader.containers
            .filter { containerLoader.selectedTypes.contains($0.type) }
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                ForEach(filteredContainers) { container in
                    Annotation("", coordinate: container.coordinate) {
                        Button {
                            selectedContainer = container
                        } label: {
                            Circle()
                                .fill(container.getColor())
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(Color.black.opacity(0.5), lineWidth: 1))
                        }
                    }

                }
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button { showingInfo = true } label: {
                        Image(systemName: "info.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
            .sheet(isPresented: $showingInfo) {
                WasteInfoView()
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        if let loc = locationManager.userLocation {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: loc,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            )
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()

                if let container = selectedContainer {
                    VStack(spacing: 12) {
                        HStack {
                            Text("Conteneur").font(.title3).bold()
                            Spacer()
                            Button { selectedContainer = nil } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }

                        Divider()

                        HStack {
                            Label(container.type.capitalized, systemImage: "trash.fill")
                                .font(.subheadline)
                                .foregroundColor(container.getColor())
                            Spacer()
                        }

                        Button {
                            openMaps(from: locationManager.userLocation, to: container.coordinate)
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Y aller").fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        Text("💡 \(container.getRecyclingTip())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: selectedContainer?.id)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal)
                    .padding(.bottom, 25)
                }

                VStack(spacing: 10) {
                    Text("Filtre des conteneurs")
                        .font(.headline)
                        .padding(.top, 5)

                    HStack {
                        ForEach(types, id: \.self) { type in
                            FilterButton(
                                type: type,
                                icon: typeIcons[type] ?? "circle",
                                color: typeColors[type] ?? .gray,
                                containerLoader: containerLoader
                            )
                        }
                    }

                    HStack {
                        ForEach(types, id: \.self) { type in
                            Text(typeNames[type] ?? type.capitalized)
                                .foregroundColor(typeColors[type] ?? .gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .font(.caption)
                    .padding(.top, 5)

                }
                .padding()
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.bottom, 20)
            }
        }
    }
}

func openMaps(from userLocation: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D) {
    guard let userLocation = userLocation else { return }
    let saddr = "\(userLocation.latitude),\(userLocation.longitude)"
    let daddr = "\(destination.latitude),\(destination.longitude)"

    if let url = URL(string: "comgooglemaps://?saddr=\(saddr)&daddr=\(daddr)&directionsmode=walking"),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else if let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&origin=\(saddr)&destination=\(daddr)&travelmode=walking") {
        UIApplication.shared.open(webURL)
    }
}

struct FilterButton: View {
    let type: String
    let icon: String
    let color: Color
    @ObservedObject var containerLoader: ContainerLoader

    var body: some View {
        Button {
            containerLoader.toggleType(type)
        } label: {
            Image(systemName: icon)
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(
                    containerLoader.selectedTypes.contains(type)
                        ? color.opacity(0.8)
                        : Color.gray.opacity(0.3)
                )
                .clipShape(Circle())
                .foregroundColor(.white)
                .overlay(Circle().stroke(color, lineWidth: 2))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
