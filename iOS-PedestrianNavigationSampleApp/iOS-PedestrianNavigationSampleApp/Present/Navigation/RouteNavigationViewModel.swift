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
    let speech: SpeechHelper = .init()
    let destination: SearchResultModel
    private var routes: [NavigationModel]
    var currentIndex: Int = 0 {
        didSet {
            self.setDisplayMessage()
        }
    }
    var maxCurrentIndex: Int = 0 {
        didSet {
            self.setVoiceMessage()
        }
    }
    @Published var currentLocation: CLLocation?
    @Published var isFinished: Bool = false
    @Published var userTrackingMode: Bool = true
    let timeInterval: TimeInterval = 0.1
    
    var routeService: RoutesService
    var cancellables = Set<AnyCancellable>()
    
    // 경로에서 가장 가까운 좌표
    var closePoint: CLLocationCoordinate2D = CLLocationCoordinate2D()
    // 경로에서 가장 가까운좌표와 현재 나의 위치와의 거리
    var distanceToClosePoint: Int = .zero
    // 경로 이탈 횟수 (20 이상)
    var countOfOutOfRoute: Int = 0
    // 경로 이탈 횟수 기준
    let countThresholdOfOutOfRoute: Int = 500
    
    // 안내 종료 판단을 위한 도착지까지 가까워진 거리 기준
    let finishThreshold: Double = 10
    @Published var isLoading: Bool = false
    
    // MARK: Test용 String
    // 목적지까지와의 거리
    var finishDistance: Double = .zero
    var distanceToNextPoint: Double = .zero
    // 경로 재요청 횟수
    var countOfReroute: Int = 0
    
    var currentRouteCoordinates: [CLLocationCoordinate2D] = []
    
    
    var currentPolyline: MKPolyline? {
//        guard let coordinate = currentLocation?.coordinate else { return nil }
//        let coordinates = routes[currentIndex].getCoordinates(at: coordinate)
        return MKPolyline(coordinates: currentRouteCoordinates, count: currentRouteCoordinates.count)
        
    }
    var nextPolylines: MKPolyline {
        let coordinates = routes[currentIndex + 1..<routes.count]
            .flatMap({
                $0.lineModels
            })
            .flatMap { $0.cooridnates }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    // MARK: Message
    // CurrentIndex 의 Model의 끝 점까지의 남은거리
    var remainDistanceInCurrentNavigationModel: Double = .zero
    // 음성 안내용 메시지
    var voiceMessage: String = ""
    // 네비게이션 화면에 표시될 메시지
    // 실시간 업데이트(남은거리 포함)
    // 예 ) 10m 후 우회전(next point description)
    var displayMessage: String = ""
    
    init(destination: SearchResultModel, routes: [NavigationModel]) {
        self.routeService = .init()
        self.destination = destination
        self.routes = routes
        self.currentIndex = 0
        self.setVoiceMessage()
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
        routeService.startUpdaingLocation(with: timeInterval)
            .sink(receiveCompletion: {
                print($0)
            }, receiveValue: { [weak self] in
                // navigationModel 배열 중 현재 나의 위치와 가장 가까운 Model의 Index 설정
                // 가장 가까운 Index 의 루트 중간에 있는것으로 간주
                // 해당 Index 의 경우 가지고 있는 좌표 값이 아닌 진행중인 PolyLine으로 간주하여 시작 좌표 값에 변동을 주어 Polyline Update
                guard let self = self else { return }
                let coordinator = $0.coordinate
                self.searchCurrentIndexByBinarySearch(from: coordinator, start: 0, end: self.routes.count - 1)
                // TODO: 현재 Index 가 가장 마지막 Index 이고, 떨어진 거리가 완료 기준 이하일 경우 안내 종료 확인 메시지
                let distanceToDestination = self.currentLocation?.coordinate.getDistance(
                    to: .init(
                        latitude: self.destination.lat,
                        longitude: self.destination.long
                    )) ?? .greatestFiniteMagnitude
                self.finishDistance = distanceToDestination
                // MARK: 목적지와 일정 거리 이하로 줄어들게 되면 안내 종료
                if distanceToDestination < finishThreshold {
                    self.stopUpdatingLocation()
                    self.isFinished = true
                } else {
                    let (currentRoutes, distance) = routes[currentIndex].getCurrentStatus(at: $0.coordinate)
                    self.currentRouteCoordinates = currentRoutes
                    self.closePoint = currentRoutes.first ?? CLLocationCoordinate2D()
                    self.distanceToClosePoint = distance
                    let nextIndex = currentIndex < routes.count - 1 ? currentIndex + 1 : currentIndex
                    self.distanceToNextPoint = $0.coordinate.getDistance(to: routes[nextIndex].pointCoordinate)
                    // TODO: 현재 Index 확인 후, 떨어진 거리를 이용하여 경로 재탐색
                    // 내 위치를 받아온 순간 경로와 가장 짧은 거리가 20m 이상인 경우 기준카운트 증가
                    if self.distanceToClosePoint > 20 {
                        self.countOfOutOfRoute += 1
                    } else {
                        self.countOfOutOfRoute = 0
                    }
                    
                    // 카운트가 최대 기준카운트보다 커지면 경로 재탐색
                    if self.countOfOutOfRoute > self.countThresholdOfOutOfRoute {
                        // 경로 재탐색
                        reroute()
                    } else {
                        // RouteService 로 현재 위치데이터를 받으면 현재 위치값을 업데이트.
                        self.currentLocation = $0
                    }
                }
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
        if start == end || start + 1 == end {
            if currentIndex < start {
                self.maxCurrentIndex = start
            }
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
            } else {
                searchCurrentIndexByBinarySearch(from: location, start: middleIndex, end: end)
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
        if let currentLocation = self.currentLocation?.coordinate {
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
                self.countOfReroute += 1
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
        self.countOfOutOfRoute = 0
        self.routes = []
    }
    
    private func setDisplayMessage() {
        if currentIndex < routes.count - 1 {
            self.displayMessage = "\(self.distanceToNextPoint) 이동 후 \(routes[currentIndex + 1].turnType.getTitle())"
        } else {
            self.displayMessage = "목적지 도착"
        }
    }
    
    private func setVoiceMessage() {
        self.voiceMessage = routes[maxCurrentIndex].turnType.getTitle()
        speech.speak(self.voiceMessage)
    }
}
