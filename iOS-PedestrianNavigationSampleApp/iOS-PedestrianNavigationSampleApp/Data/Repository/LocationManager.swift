//
//  LocationManager.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject {
    private let manager: CLLocationManager
    var locationPublisher: PassthroughSubject<CLLocation, DataError>?
    var timer: Timer?
    var heading: CLLocationDirection?
    
    override init() {
        self.manager = CLLocationManager()
        super.init()
        self.manager.delegate = self
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
    
    func startUpdatingLocation(with timeInterval: TimeInterval) -> AnyPublisher<CLLocation, DataError> {
        self.manager.startUpdatingHeading()
        self.locationPublisher = .init()
        if timer != nil {
            timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if let location = self.manager.location, let heading {
                let locationWithHeading = CLLocation(
                    coordinate: location.coordinate,
                    altitude: location.altitude,
                    horizontalAccuracy: location.horizontalAccuracy,
                    verticalAccuracy: location.verticalAccuracy,
                    course: heading,
                    speed: location.speed,
                    timestamp: location.timestamp)
                self.locationPublisher?.send(locationWithHeading)
            }
        })
        return self.locationPublisher!.eraseToAnyPublisher()
    }
    
    func stopUpdatingLocation() {
        self.timer?.invalidate()
        self.timer = nil
        self.locationPublisher = nil
        self.manager.stopUpdatingHeading()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
    }
}
