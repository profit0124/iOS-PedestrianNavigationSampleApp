//
//  SearchResultView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI
import MapKit
import Combine

struct SearchResultView: View {
    
    @EnvironmentObject var router: ViewRouter
    
    @StateObject private var viewModel: SearchResultViewModel
    @State private var mapView: MKMapView = .init(frame: .zero)
    
    init(_ text: String) {
        self._viewModel = .init(wrappedValue: SearchResultViewModel(searchText: text))
    }
    
    var body: some View {
        VStack {
            GeometryReader {
                let size = $0.size
                VStack {
                    MapViewRepresentable(mapView: $mapView,
                                         results: $viewModel.results)
                    
                    Group {
                        if viewModel.results.isEmpty {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("검색 결과가 없습니다.")
                            }
                        } else {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 12) {
                                    ForEach(viewModel.results, id: \.pKey) { result in
                                        searchListCellView(result)
                                        .padding(.vertical, 8)
                                    }
                                }
                                .padding(.top, 12)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .frame(height: size.height / 2)
                }
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
        Button {
            mapView.setRegion(
                .init(
                    center: .init(latitude: result.lat, longitude: result.long),
                    span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)),
                animated: true)
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(result.name)
                        .font(.system(size: 22, weight: .semibold))
                    
                    Text(result.newAddress)
                        .font(.system(size: 12))
                }
                Spacer()
            }
        }
        .overlay(alignment: .trailing) {
            Button(action: {
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

#Preview {
    SearchResultView("Search result")
}
