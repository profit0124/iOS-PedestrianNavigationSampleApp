//
//  SearchViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

final class SearchViewModel: ObservableObject {
    @Published var text: String
    
    init() {
        self.text = ""
    }
    
    func clearText() {
        self.text = ""
    }
}
