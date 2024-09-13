//
//  SearchTarget.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

enum SearchTarget {
    case getTotal(_ parameter: SearchDTO.RequestDTO.TotalSearchRequest)
}

extension SearchTarget: TargetType {
    var baseURL: String {
        Constant.tmapBaseURL
    }
    
    var path: String {
        "/pois"
    }
    
    var method: HttpMethod {
        switch self {
        case .getTotal:
            return .get
        }
    }
    
    var parameter: RequestParameter {
        switch self {
        case let .getTotal(parameter):
            return .query(parameter)
        }
    }
    
    var httpHeaderFields: [HttpHeaderField] {
        switch self {
        case .getTotal:
            [.accept, .appKey]
        }
    }
}
