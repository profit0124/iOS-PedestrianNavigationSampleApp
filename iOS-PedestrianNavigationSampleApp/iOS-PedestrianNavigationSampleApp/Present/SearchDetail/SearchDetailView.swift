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
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .overlay(alignment: .bottom) {
                Button {
                    viewRouter.push(.navigation(destination: viewModel.model, routes: state.routes))
                } label: {
                    Text("안내 시작")
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                        }
                }
                .padding(.bottom, 24)
                .padding(.horizontal, 16)

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
