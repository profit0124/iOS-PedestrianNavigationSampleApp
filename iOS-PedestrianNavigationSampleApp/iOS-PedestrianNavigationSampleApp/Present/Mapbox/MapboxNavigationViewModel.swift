//
//  MapboxNavigationViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/15/24.
//

import Foundation
import Combine
import CoreLocation
import MapboxDirections
import MapboxCoreNavigation

final class MapboxNavigationViewModel: ObservableObject {
    let searchModel: SearchResultModel
    let mapboxService: MapboxServiceType
    
    var cancellable = Set<AnyCancellable>()
    
    @Published var isCompleted: Bool = false
    var mapboxCoordinates: [CLLocationCoordinate2D] = []
    
    
    init(model: SearchResultModel) {
        self.searchModel = model
        self.mapboxService = MapboxService()
    }
    
    enum Action {
        case onAppear
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchMapboxDirection()
        }
    }
    
    func fetchMapboxDirection() {
        isCompleted = false
        mapboxService.fetch(CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.long), profiler: .walking)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: { [weak self] coordinates in
                guard let self = self else { return }
                self.mapboxCoordinates = coordinates
                self.isCompleted = true
            })
            .store(in: &cancellable)
    }
}
