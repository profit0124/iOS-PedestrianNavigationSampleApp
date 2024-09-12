//
//  LocationManager.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager {
    let manager: CLLocationManager
    
    init() {
        self.manager = CLLocationManager()
    }
    
    func requestAuth() {
        self.manager.requestWhenInUseAuthorization()
        
    }
    
    func getAuth() -> AnyPublisher<CLAuthorizationStatus, DataError> {
        Just(self.manager.authorizationStatus)
            .setFailureType(to: DataError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchLocation() -> AnyPublisher<CLLocationCoordinate2D, DataError> {
        Future { [weak self] promise in
            if let coordinate = self?.manager.location?.coordinate {
                promise(.success(coordinate))
            } else {
                promise(.failure(DataError.failToGetLocation))
            }
        }
        .eraseToAnyPublisher()
    }
}
