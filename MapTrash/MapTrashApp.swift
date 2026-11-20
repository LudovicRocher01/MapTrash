//
//  MapTrashApp.swift
//  MapTrash
//
//  Created by Ludovic Rocher on 18/03/2025.
//

import SwiftUI

@main
struct MapTrashApp: App {
    @State private var app = AppState()
    @State private var location = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(app)
                .environment(location)
                .environment(AppRouter.shared)
        }
    }
}
