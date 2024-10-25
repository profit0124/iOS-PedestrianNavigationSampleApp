//
//  SearchResultSimulatorView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/23/24.
//

import SwiftUI
import MapKit


struct SearchResultSimulatorView: View {
    
    @EnvironmentObject var router: ViewRouter
    
    @StateObject private var viewModel: SearchResultSimulatorViewModel
    
    init(_ text: String) {
        self._viewModel = .init(wrappedValue: SearchResultSimulatorViewModel(text))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.results, id: \.self) { result in
                        searchListCellView(result)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            viewModel.send(.fetchData)
        }
        .task {
            viewModel.send(.fetchData)
        }
    }
    
    @ViewBuilder private func searchListCellView(_ result: SearchResultModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(result.name)
                    .font(.system(size: 22, weight: .semibold))
                
                Text(result.newAddress)
                    .font(.system(size: 12))
            }
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button(action: {
//                print("search")
//                router.push(.mapboxnavigation(model: result))
                router.push(.searchDetail(selectItem: result))
            }, label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue)
                    }
            })
        }
    }
}
