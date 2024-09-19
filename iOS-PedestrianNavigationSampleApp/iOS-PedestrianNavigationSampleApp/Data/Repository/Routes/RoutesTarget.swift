//
//  RoutesTarget.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation

enum RoutesTarget {
    case postRoutes(_ parameter: RoutesDTO.RequestDTO.PostRoutes)
}

extension RoutesTarget: TargetType {
    var baseURL: String {
        Constant.tmapBaseURL
    }
    
    var path: String {
        "/routes/pedestrian?version=1"
    }
    
    var method: HttpMethod {
        switch self {
        case .postRoutes:
            return .post
        }
    }
    
    var parameter: RequestParameter {
        switch self {
        case let .postRoutes(parameter):
            return .body(parameter)
        }
    }
    
    var httpHeaderFields: [HttpHeaderField] {
        switch self {
        case .postRoutes:
            [.accept, .contentType, .appKey]
        }
    }
}
