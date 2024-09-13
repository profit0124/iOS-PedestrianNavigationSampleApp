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
    }
}
