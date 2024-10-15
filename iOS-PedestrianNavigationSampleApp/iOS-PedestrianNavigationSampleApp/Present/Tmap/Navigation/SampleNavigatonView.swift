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
                    VStack {
                        if viewModel.isFinished {
                            Text("목적지 도착")
                        } else {
                            Text("목적지까지 거리 : \(viewModel.finishDistance)")
                            Text("경로 재탐색 횟수 : \(viewModel.countOfReroute)")
                            Text("경로와의 거리 : \(viewModel.distanceToClosePoint) / 20")
                            Text("경로이탈 카운트 : \(viewModel.countOfOutOfRoute)")
                            if let speed = viewModel.currentLocation?.speed {
                                Text("speed: \(speed)")
                            }
                        }
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.blue)
                    }
                    VStack {
                        Text(viewModel.displayMessage)
                            .foregroundStyle(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.red)
                            }
                        Text(viewModel.voiceMessage)
                            .foregroundStyle(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            }
                    }
                    Spacer()
                    HStack {
                        Button {
                            viewModel.send(.stopUpdatingLocation)
                            viewRouter.pop()
                        } label: {
                            Text(viewModel.isFinished ? "뒤로가기" : "종료")
                                .foregroundStyle(.white)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.blue)
                                }
                        }
                        .padding(.bottom, 16)
                        
                        Button {
                            viewModel.userTrackingMode.toggle()
                        } label: {
                            Image(systemName: "scope")
                                .foregroundStyle(.white)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.userTrackingMode ? .blue : .gray)
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .onAppear {
            viewModel.send(.startUpdatingLocation)
        }
        
    }
}
