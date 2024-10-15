//
//  MapboxView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/15/24.
//

import SwiftUI
import MapboxMaps
import MapboxNavigation
import MapboxCoreNavigation
import MapboxDirections

struct MapboxViewRepresentable: UIViewRepresentable {
    
    func makeUIView(context: Context) -> NavigationMapView {
        return NavigationMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: NavigationMapView, context: Context) {
    }
}
