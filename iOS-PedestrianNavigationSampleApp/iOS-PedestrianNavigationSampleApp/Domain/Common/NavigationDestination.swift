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
    case navigation(destination: SearchResultModel, routes: [NavigationModel])
    case coremotionTest
    case mapboxnavigation(model: SearchResultModel)
}

extension NavigationDestination {
    @ViewBuilder func destinationView() -> some View {
        switch self {
        case .search:
            SearchView()
        case let .searchResult(text):
            #if targetEnvironment(simulator)
            SearchResultSimulatorView(text)
            #else
            SearchResultView(text)
            #endif
        case let .searchDetail(selectItem):
            #if targetEnvironment(simulator)
            RouteTestView(selectItem)
            #else
            SearchDetailView(selectItem)
            #endif
        case let .navigation(destination, routes):
            SampleNavigatonView(destination: destination, routes: routes)
        case .coremotionTest:
            CoreMotionTestView()
        case let .mapboxnavigation(model):
            MapboxNavigationView(model)
        }
    }
}
