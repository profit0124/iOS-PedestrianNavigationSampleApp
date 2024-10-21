//
//  MapboxDirectionRepository.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/16/24.
//

import Foundation
import Combine
import MapboxDirections
import MapboxCoreNavigation

protocol MapboxDirectionRepositoryProtocol {
    func fetchDirection(start: Waypoint, destination: Waypoint, profileIdentifier: ProfileIdentifier) -> AnyPublisher<RouteResponse, DataError>
}

final class MapboxDirectionRepository: MapboxDirectionRepositoryProtocol {
    func fetchDirection(start: Waypoint, destination: Waypoint, profileIdentifier: ProfileIdentifier) -> AnyPublisher<RouteResponse, DataError> {
        let options = NavigationRouteOptions(
            waypoints: [start, destination],
            profileIdentifier: profileIdentifier,
            queryItems: [
                .init(name: "steps", value: "true"),
                .init(name: "geometries", value: "geojson"),
                .init(name: "language", value: "ko")
            ]
        )
        return Future { promise in
            Directions.shared.calculate(options, completionHandler: {
                (session, result) in
                switch result {
                case .failure(let error):
                    promise(.failure(DataError.error(error)))
                    
                case .success(let response):
                    promise(.success(response))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
