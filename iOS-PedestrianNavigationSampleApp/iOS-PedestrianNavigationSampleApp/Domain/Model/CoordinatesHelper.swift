//
//  CoordinatesHelper.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/30/24.
//

import Foundation
import CoreLocation

typealias RouteCoordinates = [CLLocationCoordinate2D]

extension RouteCoordinates {
    func getShortestData(_ coordinate: CLLocationCoordinate2D) -> (Int, CLLocationCoordinate2D) {
        var closeDistance = Double.greatestFiniteMagnitude
        var closePoint = CLLocationCoordinate2D()
        for i in 0..<self.count {
            if i != self.count - 1 {
                let from = self[i]
                let to = self[i+1]
                let at = coordinate
                let point = from.getShortestPoint(from: at, to: to)
                let distance = point.getDistance(to: point)
                if distance < closeDistance {
                    closeDistance = distance
                    closePoint = point
                }
            } else {
                let distance = self[i].getDistance(to: coordinate)
                if distance < closeDistance {
                    closeDistance = distance
                    closePoint = self[i]
                }
            }
        }
        return (Int(closeDistance), closePoint)
    }
}
