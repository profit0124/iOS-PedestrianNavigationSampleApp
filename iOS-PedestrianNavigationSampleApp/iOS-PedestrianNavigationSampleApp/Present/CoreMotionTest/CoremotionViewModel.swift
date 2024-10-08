//
//  CoremotionViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/7/24.
//

import Foundation
import CoreMotion
import CoreLocation
import MapKit

class CoremotionViewModel:  NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    
    let locationManager: CLLocationManager
    let motionManager: CMMotionManager
    
    var motionData: CMDeviceMotion?
    var exepectedLocation: CLLocation?
    
    var isCurrentLocationReliable: Bool = false
    var addAnnotationCount: Int = 0
    
    override init() {
        self.locationManager = CLLocationManager()
        self.motionManager = CMMotionManager()
        super.init()
        
        self.locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .fitness
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.motionManager.startAccelerometerUpdates()
        self.motionManager.startGyroUpdates()
    }
    
    func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
            guard let data = data else { return }
            self.motionData = data
        }
    }
//    
    func setExpectedLocation(from location: CLLocation, to timeInterval: TimeInterval) {
        guard let accelerationData = self.motionManager.accelerometerData,
              let gyroData = self.motionManager.gyroData else { return }
        
        
        let acceleration = accelerationData.acceleration
        let movement = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
        
        let rotationRate = gyroData.rotationRate
        let yaw = rotationRate.z
        
        let estimatedDistance = movement * timeInterval
        
        let newLatitude = location.coordinate.latitude + (estimatedDistance / 111000) * cos(yaw)
        let newLongitude = location.coordinate.longitude + (estimatedDistance / 111000) * sin(yaw)
        
        self.exepectedLocation = CLLocation(latitude: newLatitude, longitude: newLongitude)
        self.addAnnotationCount += 1
    }
}

extension CoremotionViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        if newLocation.timestamp.timeIntervalSinceNow < -5 { return }
        if let currentLocation {
            if let exepectedLocation {
                let timeInterval = newLocation.timestamp.timeIntervalSince(currentLocation.timestamp)
                self.setExpectedLocation(from: exepectedLocation, to: timeInterval)
            } else {
                let timeInterval = newLocation.timestamp.timeIntervalSince(currentLocation.timestamp)
                self.setExpectedLocation(from: currentLocation, to: timeInterval)
            }
            
        }
        
        self.isCurrentLocationReliable = newLocation.horizontalAccuracy < 20
        self.currentLocation = newLocation
    }
}


// Kalman Filter 구현
class KalmanFilter {
    
    private var previousLocation: CLLocation?
    private var velocityX: Double = 0
    private var velocityY: Double = 0
    private let filterConstant = 0.1 // 필터 강도
    
    // 칼만 필터 처리 로직
    func process(location: CLLocation, motion: CMDeviceMotion?) -> CLLocation {
        guard let previousLocation = previousLocation else {
            self.previousLocation = location
            return location
        }
        
        let deltaX = location.coordinate.latitude - previousLocation.coordinate.latitude
        let deltaY = location.coordinate.longitude - previousLocation.coordinate.longitude
        
        // 가속도 데이터를 기반으로 속도 보정
        if let motion = motion {
            let accelerationX = motion.userAcceleration.x
            let accelerationY = motion.userAcceleration.y
            
            velocityX += accelerationX * filterConstant
            velocityY += accelerationY * filterConstant
        }
        
        let filteredLat = previousLocation.coordinate.latitude + (deltaX + velocityX) * filterConstant
        let filteredLon = previousLocation.coordinate.longitude + (deltaY + velocityY) * filterConstant
        
        let filteredLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: filteredLat, longitude: filteredLon),
            altitude: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy,
            verticalAccuracy: location.verticalAccuracy,
            timestamp: Date()
        )
        
        self.previousLocation = filteredLocation
        return filteredLocation
    }
}
