//
//  ContentView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/11/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    var body: some View {
        NavigationStack {
            SearchView()
        }
    }
}

#Preview {
    ContentView()
}
