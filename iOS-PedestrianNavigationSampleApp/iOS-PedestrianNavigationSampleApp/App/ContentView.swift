//
//  ContentView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/11/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @EnvironmentObject private var router: ViewRouter
    
    var body: some View {
        VStack(spacing: 16) {
            Button("TmapSearch") {
                router.push(.search)
            }
            .buttonStyle(RoundedRectangleButtonStyle())

            Button("CoreMotion Test") {
                router.push(.coremotionTest)
            }
            .buttonStyle(RoundedRectangleButtonStyle())
        }
    }
}

#Preview {
    ContentView()
}
