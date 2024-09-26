//
//  NavigationView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI
import MapKit

struct SampleNavigatonView: View {
    
    @StateObject var viewModel: RouteNavigationViewModel
    
    @State private var mapView: MKMapView
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(destination: SearchResultModel, routes: [NavigationModel]) {
        self._viewModel = .init(wrappedValue: .init(destination: destination, routes: routes))
        self.mapView = .init(frame: .zero)
    }
    
    var body: some View {
        ZStack {
            RouteNavigationMapView(viewModel: viewModel, mapView: $mapView)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                    Text("경로 재탐색 중")
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight:.infinity)
                .background {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                }
                
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            viewModel.send(.stopUpdatingLocation)
                            viewRouter.pop()
//                            viewModel.send(.findRoute)
                        } label: {
                            Text("종료")
                                .foregroundStyle(.white)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.blue)
                                }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .onAppear {
            viewModel.send(.startUpdatingLocation)
        }
        
    }
}
//
//#Preview {
//    SampleNavigatonView([.init(id: 0, name: "", description: "", pointCoordinate: .init(latitude: 0, longitude: 0), lineModels: [])])
//}
