//
//  SearchDetailView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

struct SearchDetailView: View {
    
    @StateObject private var viewModel: SearchDetailViewModel
    
    init(_ model: SearchResultModel) {
        self._viewModel = .init(wrappedValue: .init(model: model))
    }
    
    var body: some View {
        Text("Search detail view")
            .onAppear {
                viewModel.onAppear()
            }
    }
}
//
//#Preview {
//    SearchDetailView()
//}
