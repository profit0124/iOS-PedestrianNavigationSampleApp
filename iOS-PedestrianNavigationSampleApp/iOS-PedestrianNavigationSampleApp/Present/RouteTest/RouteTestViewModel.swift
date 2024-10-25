//
//  RouteTestViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/21/24.
//

import Foundation
import MapKit
import Combine


class RouteTestViewModel: ObservableObject {
    
    let destination: SearchResultModel
    private var routes: [NavigationModel] = []
    
    // MARK: Polyline 경로 Test용
    private var indexArray: [Int] = []
    private var coordinates: [CLLocationCoordinate2D] = []
    private var index = 0
    
    var currentIndex: Int = 0
    
    @Published var currentLocation: CLLocation?
    let timeInterval: TimeInterval = 0.1
    
    var routeService: RoutesServiceType
    var cancellables = Set<AnyCancellable>()
    
    var closePoint: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var closeDistance: Double = .greatestFiniteMagnitude
    
    var timer: Timer?
    
    init(destination: SearchResultModel) {
        self.destination = destination
        self.routeService = StubRoutesService()
    }
    
    var currentPolyline: ColorPolyline? {
        if routes.isEmpty { return nil }
        let coordinates = routes[currentIndex].lineModels
            .flatMap {
                $0.cooridnates
            }
        
        let polyline = ColorPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.color = .red
        return polyline
    }
    
    var nextPolylines: ColorPolyline? {
        if routes.isEmpty { return nil }
        let coordinates = routes[currentIndex + 1..<routes.count]
            .flatMap({
                $0.lineModels
            })
            .flatMap { $0.cooridnates }
        let polyline = ColorPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.color = .blue
        return polyline
    }
    
    
    enum Action {
        case onAppear
        case fetchRoutes
        case touchEvent(CLLocationCoordinate2D)
        case goRoute
        case changeIndex(Bool)
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            setCurrentLocation(nil)
            
        case .fetchRoutes:
            fetchRoute()
            
        case let .touchEvent(location):
            searchCurrentIndexByBinarySearch(from: location, start: 0, end: self.routes.count - 1)
            setCurrentLocation(location)
            
        case .goRoute:
            goRoute()
            
        case let .changeIndex(up):
            changeIndex(up)
        }
    }
    
    // MARK: 현재 위치 설정
    private func setCurrentLocation(_ location: CLLocationCoordinate2D?) {
        if let location {
            self.currentLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        } else {
            self.routeService.fetch(destination)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(completion)
                } receiveValue: { [weak self] result in
                    guard let self else { return }
                    if let startLocation = result.routes.first?.pointCoordinate {
                        self.currentLocation = CLLocation(latitude: startLocation.latitude, longitude: startLocation.longitude)
                    }
                    
                    self.routes = result.routes
                    self.setCoordinates()
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: 경로 재설정 요청
    private func fetchRoute() {
        if let currentLocation {
            self.routeService.fetchRoutes(
                fromPoint: currentLocation.coordinate,
                fromName: "현재위치",
                toPoint: CLLocationCoordinate2D(
                    latitude: destination.lat,
                    longitude: destination.long),
                toName: destination.name)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: { [weak self] routes in
                guard let self else { return }
                self.routes = routes
                self.setCoordinates()
            })
            .store(in: &cancellables)
        }
    }
    
    // MARK: searchCurrentIndexByBinarySearch
    private func searchCurrentIndexByBinarySearch(from location: CLLocationCoordinate2D, start: Int, end: Int) {
        let middleIndex = (start + end) / 2
        if middleIndex == start {
            if location == routes[end].pointCoordinate {
                self.setCurrentIndex(end, location)
            } else {
                self.setCurrentIndex(start, location)
            }
        } else {
            let leftSideFrom = routes[start].pointCoordinate
            let leftSideTo = routes[middleIndex].pointCoordinate
            
            if leftSideTo == location {
                self.setCurrentIndex(middleIndex, location)
                return
            }
            
            let leftSideClosedPoint = location.getShortestPoint(from: leftSideFrom, to: leftSideTo)
            let leftSideDistance = location.getDistance(to: leftSideClosedPoint)
            
            let rightSideFrom = routes[middleIndex].pointCoordinate
            let rightSideTo = routes[end].pointCoordinate
            
            if rightSideTo == location {
                self.setCurrentIndex(end, location)
                return
            }
            
            let rightSideClosedPoint = location.getShortestPoint(from: rightSideFrom, to: rightSideTo)
            let rightSideDistance = location.getDistance(to: rightSideClosedPoint)
            if leftSideDistance < rightSideDistance {
                searchCurrentIndexByBinarySearch(from: location, start: start, end: middleIndex)
            } else {
                searchCurrentIndexByBinarySearch(from: location, start: middleIndex, end: end)
            }
        }
    }
    
    // MARK: set current index
    private func setCurrentIndex(_ index: Int, _ location: CLLocationCoordinate2D) {
        self.currentIndex = index
        let (currentRoute, distance) = routes[currentIndex].getCurrentStatus(at: location)
        self.closePoint = currentRoute.first ?? CLLocationCoordinate2D()
        closeDistance = Double(distance)
    }
    
    // MARK: Set Coordinates
    private func setCoordinates() {
        var index = 0
        for route in routes {
            route.lineModels.forEach { lineModel in
                lineModel.cooridnates.forEach { coordinate in
                    if index < routes.count - 1, coordinate != routes[index + 1].pointCoordinate {
                        coordinates.append(coordinate)
                        indexArray.append(index)
                    } else {
                        if index >= routes.count - 1 {
                            coordinates.append(coordinate)
                            indexArray.append(index)
                        }
                    }
                }
            }
            index += 1
        }
    }
    
    // MARK: Go route
    private func goRoute() {
        if let timer {
            timer.invalidate()
            self.timer = nil
            return
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            if index < self.coordinates.count {
                let coordinate = self.coordinates[index]
                self.setCurrentLocation(coordinates[index])
                self.searchCurrentIndexByBinarySearch(from: coordinate, start: 0, end: self.routes.count - 1)
                index += 1
            } else {
                timer.invalidate()
            }
        })
    }
    
    // MARK: func changeIndex
    private func changeIndex(_ up: Bool) {
        if up {
            if index < coordinates.count - 1 {
                index += 1
            }
        } else {
            if index > 0 {
                index -= 1
            }
        }
        let coordinate = self.coordinates[index]
        self.setCurrentLocation(coordinates[index])
        self.searchCurrentIndexByBinarySearch(from: coordinate, start: 0, end: self.routes.count - 1)
    }
    
}

class ColorPolyline: MKPolyline {
    var color: UIColor?
}
