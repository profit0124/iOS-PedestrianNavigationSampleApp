//
//  ContentView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/11/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @StateObject private var router = ViewRouter()
    
    var body: some View {
            SearchView()
    }
}

#Preview {
    ContentView()
}
