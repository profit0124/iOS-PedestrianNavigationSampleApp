//
//  MapboxService.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/16/24.
//

import Foundation
import Combine
import CoreLocation
import MapboxDirections


protocol MapboxServiceType {
    func fetch(_ end: CLLocationCoordinate2D, profiler: ProfileIdentifier) -> AnyPublisher<[CLLocationCoordinate2D], ServiceError>
}

final class MapboxService: MapboxServiceType {
    
    var locationManager: LocationManager
    var repository: MapboxDirectionRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        self.locationManager = LocationManager()
        self.repository = MapboxDirectionRepository()
    }
    
    func fetch(_ end: CLLocationCoordinate2D, profiler: ProfileIdentifier) -> AnyPublisher<[CLLocationCoordinate2D], ServiceError> {
        let destination = Waypoint(coordinate: end)
        return locationManager.fetchLocation()
            .map {
                Waypoint(coordinate: $0)
            }
        // Location 을 받아온 후 해당 Location 으로 start 위치 지정
            .flatMap { [weak self] start in
                if let self {
                    return self.repository.fetchDirection(start: start, destination: destination, profileIdentifier: profiler)
                } else {
                    return Future { promise in
                        promise(.failure(DataError.failToGetLocation))
                    }
                    .eraseToAnyPublisher()
                }
            }
        // Model 로 변경
            .compactMap {
                if let routes = $0.routes {
                    let result = routes
                        .flatMap { $0.legs }
                        .flatMap { $0.steps }
                        .compactMap { $0.shape?.coordinates }
                        .flatMap { $0 }
                        .map {
                            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                        }
                    return result
                } else {
                    return nil
                }
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}
