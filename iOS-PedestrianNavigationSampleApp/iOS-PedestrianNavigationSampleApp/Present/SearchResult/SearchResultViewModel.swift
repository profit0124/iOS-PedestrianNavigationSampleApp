//
//  SearchResultViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

final class SearchResultViewModel: ObservableObject {
    @Published var searchText: String
    
    init(searchText: String) {
        self.searchText = searchText
    }
}
