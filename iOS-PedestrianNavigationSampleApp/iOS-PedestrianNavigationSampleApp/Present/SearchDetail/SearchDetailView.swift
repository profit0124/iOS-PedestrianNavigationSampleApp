//
//  SearchDetailView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI
import MapKit

struct SearchDetailView: View {
    
    @StateObject private var viewModel: SearchDetailViewModel
    @State private var mapView: MKMapView
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(_ model: SearchResultModel) {
        self._viewModel = .init(wrappedValue: .init(model: model))
        self.mapView = MKMapView(frame: .zero)
    }
    
    var body: some View {
        if let state = viewModel.state {
            VStack {
                SearchDetailMapView(mapView: $mapView, viewModel: viewModel)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(state.routes) { route in
                            Button {
                                viewModel.send(.selectItem(route))
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(route.description)
                                            .font(.system(size: 16, weight: .semibold))
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 8)
                                    }
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .overlay(alignment: .trailing) {
                                Button {
                                    viewRouter.push(.navigation(model: route))
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .foregroundStyle(.white)
                                        .frame(width: 20, height: 20)
                                        .padding(10)
                                        .background {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.blue)
                                        }
                                }
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    viewModel.send(.fetch)
                }
        }
        
    }
}

#Preview {
    SearchDetailView(SearchResultModel.mock1)
}
