//
//  NavigationDestination.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case search
    case searchResult(text: String)
    case searchDetail(selectItem: SearchResultModel)
    case navigation(model: [NavigationModel])
}

extension NavigationDestination {
    @ViewBuilder func destinationView() -> some View {
        switch self {
        case .search:
            SearchView()
        case let .searchResult(text):
            SearchResultView(text)
        case let .searchDetail(selectItem):
            SearchDetailView(selectItem)
        case let .navigation(model):
            SampleNavigatonView(model)
        }
    }
}
