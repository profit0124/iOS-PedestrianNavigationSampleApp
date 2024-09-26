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
    private let destination: SearchResultModel
    private var routes: [NavigationModel]
    @Published var currentIndex: Int = 0
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var isFinished: Bool = false
    
    var routeService: RoutesService
    var cancellables = Set<AnyCancellable>()
    
    var closePoint: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var distanceToClosePoint: Double = .zero
    var basisCount: Int = 0
    var maxBasisCount: Int = 10
    @Published var isLoading: Bool = false
    
    var inRoute: Bool = true
    
    var currentPolyline: MKPolyline? {
        guard let coordinate = currentLocation else { return nil }
        let coordinates = routes[currentIndex].getCoordinates(at: coordinate)
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
        
    }
    var nextPolylines: MKPolyline {
        let coordinates = routes[currentIndex + 1..<routes.count]
            .flatMap({
                $0.lineModels
            })
            .flatMap { $0.cooridnates }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    init(destination: SearchResultModel, routes: [NavigationModel]) {
        self.routeService = .init()
        self.destination = destination
        self.routes = routes
        self.currentIndex = 0
        self.currentLocation = routes.first?.lineModels.first?.cooridnates.first
    }
    
    enum Action {
        case startUpdatingLocation
        case stopUpdatingLocation
        case findRoute
    }
    
    func send(_ action: Action) {
        switch action {
        case .startUpdatingLocation:
            startUpdaingLocation()
        case .stopUpdatingLocation:
            stopUpdatingLocation()
        case .findRoute:
            reroute()
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
//                self?.getCurrentIndex(from: $0)
                guard let self = self else { return }
                self.searchCurrentIndexByBinarySearch(from: $0, start: 0, end: self.routes.count - 1)
                // TODO: 현재 Index 가 가장 마지막 Index 이고, 떨어진 거리가 완료 기준 이하일 경우 안내 종료 확인 메시지
                
                // TODO: 현재 Index 확인 후, 떨어진 거리를 이용하여 경로 재탐색
                // 내 위치를 받아온 순간 경로와 가장 짧은 거리가 20m 이상인 경우 기준카운트 증가
                if self.distanceToClosePoint > 20 {
                    self.basisCount += 1
                } else {
                    self.basisCount = 0
                }
                
                // 카운트가 최대 기준카운트보다 커지면 경로 재탐색
                if self.basisCount > self.maxBasisCount {
                    // 경로 재탐색
                    reroute()
                } else {
                    self.currentLocation = $0
                }
                // RouteService 로 현재 위치데이터를 받으면 현재 위치값을 업데이트.
            })
            .store(in: &cancellables)
    }
    
    private func stopUpdatingLocation() {
        // locationManager 에 stop 전달
        routeService.stopUpdatingLocation()
        // 위치데이터 Publisher 구독 해제
        cancellables.removeAll()
        
    }
    
    // 기존 LinearSearch
    private func getCurrentIndex(from location: CLLocationCoordinate2D) {
        var minimumDistance = Double.greatestFiniteMagnitude
        var tempIndex = currentIndex
        
        for i in 0..<routes.count {
            let distance = routes[i].getMinimuDistance(from: location)
            if minimumDistance > distance {
                tempIndex = i
                minimumDistance = distance
            }
        }
        currentIndex = tempIndex
    }
    // 개선 BinarySearch
    private func searchCurrentIndexByBinarySearch(from location: CLLocationCoordinate2D, start: Int, end: Int) {
        if start == end {
            currentIndex = start
        } else if start + 1 == end {
            currentIndex = start
        } else {
            let middleIndex = (start + end) / 2
            let leftSideFrom = routes[start].pointCoordinate
            let leftSideTo = routes[middleIndex].pointCoordinate
            let leftSideClosedPoint = location.getShortestPoint(from: leftSideFrom, to: leftSideTo)
            let leftSideDistance = location.getDistance(to: leftSideClosedPoint)
            
            let rightSideFrom = routes[middleIndex].pointCoordinate
            let rightSideTo = routes[end].pointCoordinate
            let rightSideClosedPoint = location.getShortestPoint(from: rightSideFrom, to: rightSideTo)
            let rightSideDistance = location.getDistance(to: rightSideClosedPoint)
            if leftSideDistance < rightSideDistance {
                searchCurrentIndexByBinarySearch(from: location, start: start, end: middleIndex)
                self.distanceToClosePoint = leftSideDistance
                self.closePoint = leftSideClosedPoint
            } else {
                searchCurrentIndexByBinarySearch(from: location, start: middleIndex, end: end)
                self.distanceToClosePoint = rightSideDistance
                self.closePoint = rightSideClosedPoint
            }
        }
    }
    
    private func reroute() {
        // 기존 구독 해제
        self.stopUpdatingLocation()
        // 기존 데이터 reset
        self.reset()
        self.isLoading = true
        // route 재설정
        if let currentLocation {
            self.routeService.fetchRoutes(
                fromPoint: currentLocation,
                fromName: "현재위치",
                toPoint: CLLocationCoordinate2D(
                    latitude: destination.lat,
                    longitude: destination.long
                ),
                toName: destination.name
            )
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {completion in
                // TODO: fail 에 대한 처리
            }, receiveValue: { [weak self] routes in
                guard let self = self else { return }
                self.routes = routes
                self.isLoading = false
                // 위치데이터 구독 시작
                self.startUpdaingLocation()
            })
            .store(in: &cancellables)
        }
    }
    
    private func reset() {
        self.currentIndex = 0
        self.closePoint = CLLocationCoordinate2D()
        self.distanceToClosePoint = .zero
        self.basisCount = 0
        self.routes = []
    }
}
