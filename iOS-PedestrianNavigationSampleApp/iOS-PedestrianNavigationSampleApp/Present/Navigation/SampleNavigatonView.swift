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
    
    init(_ model: [NavigationModel]) {
        self._viewModel = .init(wrappedValue: .init(navigationModels: model))
        self.mapView = .init(frame: .zero)
    }
    
    var body: some View {
        ZStack {
            RouteNavigationMapView(viewModel: viewModel, mapView: $mapView)
                .ignoresSafeArea()
            Button {
                viewModel.send(.stopUpdatingLocation)
                viewRouter.pop()
            } label: {
                Text("안내 종료")
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
        .onAppear {
            viewModel.send(.startUpdatingLocation)
        }
        
    }
}

#Preview {
    SampleNavigatonView([.init(id: 0, name: "", description: "", pointCoordinate: .init(latitude: 0, longitude: 0), lineModels: [])])
}
