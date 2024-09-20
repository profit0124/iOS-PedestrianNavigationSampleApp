//
//  RoutesService.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation
import MapKit
import Combine

protocol RoutesServiceType {
    func fetch(_ model: SearchResultModel) -> AnyPublisher<SearchDetailViewModel.State, ServiceError>
    
    func startUpdaingLocation() -> AnyPublisher<CLLocationCoordinate2D, ServiceError>
}

final class RoutesService: RoutesServiceType {
    
    var manager: LocationManager
    var repository: RoutesRepositoryProtocol
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        self.manager = LocationManager()
        self.repository = RoutesRepository()
    }
    
    func fetch(_ model: SearchResultModel) -> AnyPublisher<SearchDetailViewModel.State, ServiceError> {
        manager.fetchLocation()
            .map { value in
                RoutesDTO.RequestDTO.PostRoutes(
                    startX: value.longitude,
                    startY: value.latitude,
                    endX: model.long,
                    endY: model.lat,
                    startName: "현재위치".utf8Encode() ?? "",
                    endName: model.name.utf8Encode() ?? "")
            }
            .flatMap { [weak self] value in
                if let self {
                    return self.repository.fetchRoutes(value)
                } else {
                    return Future { promise in
                        promise(.failure(DataError.urlError))
                    }
                    .eraseToAnyPublisher()
                }
            }
            .compactMap {
                $0.toSearchDetailModel()
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func startUpdaingLocation() -> AnyPublisher<CLLocationCoordinate2D, ServiceError> {
        manager.startUpdatingLocation()
            .mapError{ .error($0) }
            .eraseToAnyPublisher()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}
