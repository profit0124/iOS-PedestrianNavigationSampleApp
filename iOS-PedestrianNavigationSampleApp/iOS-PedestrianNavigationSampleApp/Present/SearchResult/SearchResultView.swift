//
//  SearchResultView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

struct SearchResultView: View {
    
    @StateObject private var viewModel: SearchResultViewModel
    
    init(_ text: String) {
        self._viewModel = .init(wrappedValue: SearchResultViewModel(searchText: text))
    }
    
    var body: some View {
        Text(viewModel.searchText)
    }
}

#Preview {
    SearchResultView("Search result")
}
