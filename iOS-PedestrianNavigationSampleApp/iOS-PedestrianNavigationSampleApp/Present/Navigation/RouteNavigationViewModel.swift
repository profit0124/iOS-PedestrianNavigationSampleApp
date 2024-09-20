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
    
    var currentPolyline: MKPolyline? {
        guard let coordinate = currentLocation else { return nil }
        let coordinates = navigationModels[currentIndex].getCoordinates(at: coordinate)
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
                // navigationModel 배열 중 현재 나의 위치와 가장 가까운 Model의 Index 설정
                // 가장 가까운 Index 의 루트 중간에 있는것으로 간주
                // 해당 Index 의 경우 가지고 있는 좌표 값이 아닌 진행중인 PolyLine으로 간주하여 시작 좌표 값에 변동을 주어 Polyline Update
                self?.getCurrentIndex(from: $0)
                // TODO: 현재 Index 가 가장 마지막 Index 이고, 떨어진 거리가 완료 기준 이하일 경우 안내 종료 확인 메시지
                
                // TODO: 현재 Index 확인 후, 떨어진 거리를 이용하여 경로 재탐색
                
                // RouteService 로 현재 위치데이터를 받으면 현재 위치값을 업데이트.
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
