//
//  NavigationModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation
import MapKit

struct NavigationModel: Identifiable {
    let id: Int
    let name: String
    let description: String
    let pointCoordinate: CLLocationCoordinate2D
    let lineModels: [MKPolyLineModel]
}

extension NavigationModel: Equatable {
    static func == (lhs: NavigationModel, rhs: NavigationModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension NavigationModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NavigationModel {
    func getDestination() -> CLLocationCoordinate2D {
        if let coordinate = lineModels.last?.cooridnates.last {
            return coordinate
        }
        return self.pointCoordinate
    }
    
    func getMinimuDistance(from location: CLLocationCoordinate2D) -> Double {
        let destinationPoint = getDestination()
        let shortestPoint = location.getShortestPoint(from: pointCoordinate, to: destinationPoint)
        return location.getDistance(to: shortestPoint)
    }
}

struct MKPolyLineModel: Identifiable {
    let id: Int
    let name: String
    let description: String
    let cooridnates: [CLLocationCoordinate2D]
}

extension MKPolyLineModel: Equatable {
    static func == (lhs: MKPolyLineModel, rhs: MKPolyLineModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension MKPolyLineModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
