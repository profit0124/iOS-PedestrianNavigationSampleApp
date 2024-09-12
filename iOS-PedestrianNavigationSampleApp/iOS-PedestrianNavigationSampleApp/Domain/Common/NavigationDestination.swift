//
//  NavigationDestination.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case search
    case searchResult
    case searchDetail
    case navigation
}

extension NavigationDestination {
    @ViewBuilder func destinationView() -> some View {
        switch self {
        case .search:
            SearchView()
        case .searchResult:
            SearchResultView()
        case .searchDetail:
            SearchDetailView()
        case .navigation:
            SampleNavigatonView()
        }
    }
}
