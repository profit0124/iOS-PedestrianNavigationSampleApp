//
//  SearchView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var router: ViewRouter
    
    var body: some View {
        Button {
            router.push(.searchResult)
        } label: {
            Text("go to search result")
        }

    }
}

#Preview {
    SearchView()
        .environmentObject(ViewRouter())
}
