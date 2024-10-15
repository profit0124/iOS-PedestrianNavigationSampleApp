//
//  LocationManager.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import CoreLocation
import CoreMotion
import Combine

class LocationManager: NSObject {
    private let locationManager: CLLocationManager
    private let motionManager: CMMotionManager
    var locationPublisher: PassthroughSubject<CLLocation, DataError>?
    var timer: Timer?
    var heading: CLLocationDirection?
    
    var adjuestedLocation: CLLocation?
    
    override init() {
        self.locationManager = CLLocationManager()
        self.motionManager = CMMotionManager()
        super.init()
        self.locationManager.delegate = self
        
        self.motionManager.startGyroUpdates()
        self.motionManager.startAccelerometerUpdates()
    }
    
    func requestAuth() {
        self.locationManager.requestWhenInUseAuthorization()
        
    }
    
    func getAuth() -> AnyPublisher<CLAuthorizationStatus, DataError> {
        Just(self.locationManager.authorizationStatus)
            .setFailureType(to: DataError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchLocation() -> AnyPublisher<CLLocationCoordinate2D, DataError> {
        Future { [weak self] promise in
            if let coordinate = self?.locationManager.location?.coordinate {
                promise(.success(coordinate))
            } else {
                promise(.failure(DataError.failToGetLocation))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func startUpdatingLocation(with timeInterval: TimeInterval) -> AnyPublisher<CLLocation, DataError> {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        self.locationPublisher = .init()
        if timer != nil {
            timer = nil
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            guard let self else { return }
            if let location = self.adjuestedLocation, let heading {
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
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopUpdatingHeading()
    }
    
    // 정확도에 따라 AdjustedLocation 에 사용되는 locations 비율 변경
    func setAdjectedLocation(with location: CLLocation) {
        if location.horizontalAccuracy < 20 {
            self.adjuestedLocation = location
        } else if location.horizontalAccuracy < 40 {
            updateAdjustedLocation(with: location, originalRatio: 0.8)
        } else {
            let originalRatio = (100 - location.horizontalAccuracy >= 0 ? 100 - location.horizontalAccuracy : 0) / 100
            updateAdjustedLocation(with: location, originalRatio: originalRatio)
        }
    }
    
    func updateAdjustedLocation(with location: CLLocation, originalRatio: Double)  {
        let newRatio = 1 - originalRatio
        guard let previousLocation = self.adjuestedLocation else { return }
        let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
        guard let expectedLocation = makeExpectedLocation(timeInterval) else { return }
        let newLatitude = location.coordinate.latitude * originalRatio + expectedLocation.coordinate.latitude * newRatio
        let newLongitude = location.coordinate.longitude * originalRatio + expectedLocation.coordinate.longitude * newRatio
        self.adjuestedLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: newLatitude,
                longitude: newLongitude),
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            course: location.course,
            speed: location.speed,
            timestamp: location.timestamp
        )
    }
    
    func makeExpectedLocation(_ timeInterval: TimeInterval) -> CLLocation? {
        guard let acceletedData = self.motionManager.accelerometerData,
              let gyroData = self.motionManager.gyroData,
              let adjuestedLocation = self.adjuestedLocation
        else { return nil }
        
        let acceletation = acceletedData.acceleration
        let movement = sqrt(pow(acceletation.x, 2) + pow(acceletation.y, 2) + pow(acceletation.z, 2))
        
        let estimatedDistance = movement * timeInterval
        
        let gyro = gyroData.rotationRate
        let yaw = gyro.z
        
        let newLatitude = adjuestedLocation.coordinate.latitude + (estimatedDistance / 111000) * cos(yaw)
        let newLongitude = adjuestedLocation.coordinate.longitude + (estimatedDistance / 111000) * sin(yaw)
        
        return CLLocation(latitude: newLatitude, longitude: newLongitude)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if location.timestamp.timeIntervalSinceNow < -5 { return }
        setAdjectedLocation(with: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
    }
}
