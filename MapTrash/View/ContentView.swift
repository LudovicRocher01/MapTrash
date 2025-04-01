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
    @State private var showingInfo: Bool = false


    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 43.7102, longitude: 7.2620),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    @State private var selectedContainer: Container?

    var filteredContainers: [Container] {
        containerLoader.containers.filter { containerLoader.selectedTypes.contains($0.type) }
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(filteredContainers) { container in
                    Annotation("", coordinate: container.coordinate) {
                        Button(action: {
                            selectedContainer = container
                        }) {
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
                    Button(action: { showingInfo = true }) {
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
                    Button(action: {
                        if let userLocation = locationManager.userLocation {
                            cameraPosition = .region(
                                MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            )
                        }
                    }) {
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
                            Text("Conteneur")
                                .font(.title3).bold()
                            Spacer()
                            Button(action: {
                                selectedContainer = nil
                            }) {
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

                        Button(action: {
                            openMaps(from: locationManager.userLocation, to: container.coordinate)
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Y aller")
                                    .fontWeight(.semibold)
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
                        FilterButton(type: "VERRE", color: .green, containerLoader: containerLoader)
                        FilterButton(type: "TEXTILE", color: .blue, containerLoader: containerLoader)
                        FilterButton(type: "EMBALLAGES MENAGERS", color: .yellow, containerLoader: containerLoader)
                        FilterButton(type: "ORDURES MENAGERES", color: .red, containerLoader: containerLoader)
                        FilterButton(type: "PAPIER", color: .orange, containerLoader: containerLoader)
                    }

                    HStack {
                        Text("Verre").foregroundColor(.green)
                        Text("Textile").foregroundColor(.blue)
                        Text("Emballages Ménagers").foregroundColor(.yellow)
                        Text("Ordures Ménagères").foregroundColor(.red)
                        Text("Papier").foregroundColor(.orange)
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

    if let url = URL(string: "comgooglemaps://?saddr=\(userLocation.latitude),\(userLocation.longitude)&daddr=\(destination.latitude),\(destination.longitude)&directionsmode=walking"),
       UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else {
        if let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&origin=\(userLocation.latitude),\(userLocation.longitude)&destination=\(destination.latitude),\(destination.longitude)&travelmode=walking") {
            UIApplication.shared.open(webURL)
        }
    }
}


struct FilterButton: View {
    let type: String
    let color: Color
    @ObservedObject var containerLoader: ContainerLoader

    var body: some View {
        Button(action: {
            containerLoader.toggleType(type)
        }) {
            Text(type.prefix(1))
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(containerLoader.selectedTypes.contains(type) ? color.opacity(0.8) : Color.gray.opacity(0.3))
                .clipShape(Circle())
                .foregroundColor(.white)
                .overlay(
                    Circle().stroke(color, lineWidth: 2)
                )
        }
    }
}
