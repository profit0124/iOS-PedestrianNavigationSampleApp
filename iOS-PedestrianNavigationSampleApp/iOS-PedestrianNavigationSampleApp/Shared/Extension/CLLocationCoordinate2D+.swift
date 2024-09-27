//
//  CLLocationCoordinate2D+.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/20/24.
//

import CoreLocation

extension CLLocationCoordinate2D {
    /// vector AB 와 점 C 의 최소 거리의 위치 좌표 구하는 공식
    func getShortestPoint(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // A좌표
        let fromPointX = from.latitude
        let fromPointY = from.longitude
        // B좌표
        let endPointX = to.latitude
        let endPointY = to.longitude
        // 점 C
        let atPointX = self.latitude
        let atPointY = self.longitude
        
        let vectorABX = endPointX - fromPointX
        let vectorABY = endPointY  - fromPointY
        
        let vectorACX = atPointX - fromPointX
        let vectorACY = atPointY - fromPointY
        
        // AC 에 AB 를 투영한 값 구하기
        let ab_ab = vectorABX * vectorABX + vectorABY * vectorABY
        let ab_ac = vectorABX * vectorACX + vectorABY * vectorACY
        let t = max(0, min(1, ab_ac / ab_ab))
        
        // 가장 가까운 좌표 구하기
        let lat = fromPointX + t * vectorABX
        let lon = fromPointY + t * vectorABY
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    /// CLLocationCoordinate2D 로 거리 구하기
    /// 단위는 m예상
    func getDistance(to: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return to.distance(from: from)
    }
}
