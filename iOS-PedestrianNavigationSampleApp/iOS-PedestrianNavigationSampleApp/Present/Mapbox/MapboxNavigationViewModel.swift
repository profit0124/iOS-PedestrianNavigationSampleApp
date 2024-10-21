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
    private let mapboxService: MapboxServiceType
    private let routeService: RoutesService
    
    var cancellable = Set<AnyCancellable>()
    
    @Published var isCompleted: Bool = false
    var mapboxCoordinates: [CLLocationCoordinate2D]?
    private var tmapModel: [NavigationModel]?
    
    var tmapCoordinates: [CLLocationCoordinate2D]? {
        return tmapModel?.flatMap { $0.lineModels }.flatMap { $0.cooridnates }
    }
    
    init(model: SearchResultModel) {
        self.searchModel = model
        self.mapboxService = MapboxService()
        self.routeService = RoutesService()
    }
    
    enum Action {
        case onAppear
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchMapboxDirection()
            fetchTmapDirection()
        }
    }
    
    func fetchMapboxDirection() {
        isCompleted = false
        self.mapboxCoordinates = nil
        mapboxService.fetch(CLLocationCoordinate2D(latitude: searchModel.lat, longitude: searchModel.long), profiler: .walking)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: { [weak self] coordinates in
                guard let self = self else { return }
                self.mapboxCoordinates = coordinates
                self.checkIsCompleted()
            })
            .store(in: &cancellable)
    }
    
    func fetchTmapDirection() {
        isCompleted = false
        self.tmapModel = nil
        routeService.fetch(searchModel)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.tmapModel = result.routes
                self.checkIsCompleted()
                
            })
            .store(in: &cancellable)
    }
    
    func checkIsCompleted() {
        if tmapModel != nil && mapboxCoordinates != nil {
            isCompleted = true
        }
    }
}
