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
    var locationPublisher: PassthroughSubject<CLLocationCoordinate2D, DataError>?
    var timer: Timer?
    var timeInterval: TimeInterval = 3
    
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
    
    func startUpdatingLocation() -> AnyPublisher<CLLocationCoordinate2D, DataError> {
        self.locationPublisher = .init()
        if timer != nil {
            timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if let location = self.manager.location {
                self.locationPublisher?.send(location.coordinate)
            }
        })
        return self.locationPublisher!.eraseToAnyPublisher()
    }
    
    func stopUpdatingLocation() {
        self.timer?.invalidate()
        self.timer = nil
        self.locationPublisher = nil
    }
}

extension LocationManager: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let publisher = locationPublisher, let location = locations.first {
//            publisher.send(location.coordinate)
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
//        // TODO: 
//    }
}
