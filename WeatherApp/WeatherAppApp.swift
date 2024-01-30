//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Emily Wu on 1/30/24.
//

import SwiftUI
import FirebaseCore

@main
struct WeatherAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
