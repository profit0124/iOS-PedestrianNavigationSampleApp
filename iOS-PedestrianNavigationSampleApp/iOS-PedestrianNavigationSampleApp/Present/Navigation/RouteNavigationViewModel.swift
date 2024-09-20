//
//  RouteNavigationViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/19/24.
//

import Foundation
import MapKit
import Combine

final class RouteNavigationViewModel: ObservableObject {
    private var navigationModels: [NavigationModel]
    @Published var currentIndex: Int = 0
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var isFinished: Bool = false
    
    var routeService: RoutesService
    var cancellables = Set<AnyCancellable>()
    
    var count = 0
    
    var currentPolyline: MKPolyline {
        let coordinates = navigationModels[currentIndex].lineModels.flatMap{ $0.cooridnates }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
        
    }
    var nextPolylines: MKPolyline {
        let coordinates = navigationModels[currentIndex + 1..<navigationModels.count]
            .flatMap({
                $0.lineModels
            })
            .flatMap { $0.cooridnates }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    init(navigationModels: [NavigationModel]) {
        self.routeService = .init()
        self.navigationModels = navigationModels
        self.currentIndex = 0
        self.currentLocation = navigationModels.first?.lineModels.first?.cooridnates.first
    }
    
    enum Action {
        case startUpdatingLocation
        case stopUpdatingLocation
    }
    
    func send(_ action: Action) {
        switch action {
        case .startUpdatingLocation:
            startUpdaingLocation()
        case .stopUpdatingLocation:
            stopUpdatingLocation()
        }
    }
    
    private func startUpdaingLocation() {
        routeService.startUpdaingLocation()
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: { [weak self] in
                self?.getCurrentIndex(from: $0)
                self?.currentLocation = $0
            })
            .store(in: &cancellables)
    }
    
    private func stopUpdatingLocation() {
        cancellables.removeAll()
        routeService.stopUpdatingLocation()
    }
    
    private func getCurrentIndex(from location: CLLocationCoordinate2D) {
        var minimumDistance = Double.greatestFiniteMagnitude
        var tempIndex = currentIndex
        
        for i in 0..<navigationModels.count {
            let distance = navigationModels[i].getMinimuDistance(from: location)
            if minimumDistance > distance {
                tempIndex = i
                minimumDistance = distance
            }
        }
        currentIndex = tempIndex
    }
}
