//
//  iOS_PedestrianNavigationSampleAppApp.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/11/24.
//

import SwiftUI

@main
struct iOS_PedestrianNavigationSampleAppApp: App {
    
    @StateObject private var router = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                Group {
                    ContentView()
                }
                .navigationDestination(for: NavigationDestination.self) {
                    $0.destinationView()
                }
            }
            .environmentObject(router)
            
        }
    }
}
