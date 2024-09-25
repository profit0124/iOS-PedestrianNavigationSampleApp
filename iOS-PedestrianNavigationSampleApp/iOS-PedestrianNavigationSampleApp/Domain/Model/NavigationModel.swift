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
    /// 해당 Point 의 마지막 좌표 확인
    func getDestination() -> CLLocationCoordinate2D {
        if let coordinate = lineModels.last?.cooridnates.last {
            return coordinate
        }
        return self.pointCoordinate
    }
    
    /// 해당 Point 의 시작점과 끝점의 직선과 임의의 좌표와의 최단 거리
    /// 임의의 좌표와 Point 들 간의 최단 거리를 확인하기 위함
    /// 최단거리가 되는 Point 라인을 이동중으로 간주
    func getMinimuDistance(from location: CLLocationCoordinate2D) -> Double {
        let destinationPoint = getDestination()
        let shortestPoint = location.getShortestPoint(from: pointCoordinate, to: destinationPoint)
        return location.getDistance(to: shortestPoint)
    }
    
    /// 진행중인 라인의 중간 Index 확인
    func getMiddleIndex(at location: CLLocationCoordinate2D) -> (Int, CLLocationCoordinate2D) {
        let coordinates = lineModels.flatMap({ $0.cooridnates })
        var index = 0
        var basisDistance = Double.greatestFiniteMagnitude
        var result: CLLocationCoordinate2D = .init()
        for i in 0..<coordinates.count - 1 {
            let from = coordinates[i]
            let to = coordinates[i+1]
            let point = location.getShortestPoint(from: from, to: to)
            let distance = location.getDistance(to: point)
            if basisDistance > distance {
                index = i
                basisDistance = distance
                result = point
            }
        }
        return (index, result)
    }
    
    /// 진행중인 Point 일때 지나간 경로를 제외한 남은 Coordinates를 얻기 위함
    func getCoordinates(at location: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        let basis = getMiddleIndex(at: location)
        // MARK: basis.1 을 선택한 이유는 이동중인 Line 업데이트 시에 내 위치와 가장 가까운 라인의 점을 시작점으로 바꾸기 위함
        let result = [basis.1]
        let additionalCoordinates = lineModels
            .flatMap{ $0.cooridnates }
            .enumerated()
            .filter { (index, _) in
                // 시작점 다음 Index 부터 라인에 추가
                index > basis.0
            }
            .map { $0.element }
        return result + additionalCoordinates
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
