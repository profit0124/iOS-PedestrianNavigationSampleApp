//
//  RoutesRequestDTO.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation

extension RoutesDTO.RequestDTO {
    struct PostRoutes: Encodable {
        let startX: Double
        let startY: Double
        let endX: Double
        let endY: Double
        let startName: String
        let endName: String
        /// 0: 추천
        /// 4: 추천 + 대로 우선
        /// 10: 최단
        /// 30: 최단 + 계단 제외
        let searchOption = 30
    }
}
