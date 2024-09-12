//
//  Request.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import CoreLocation

extension SearchDTO.RequestDTO {
    struct TotalSearchRequest: Encodable {
        let version: Int = 1
        let searchCount: Int = 20
        let searchType: String = "all"
        let searchKeyword: String
        let centerLon: Double
        let centerLat: Double
        let page: Int
    }
}

extension SearchDTO.RequestDTO.TotalSearchRequest {
    init(_ text: String, lat: Double, lon: Double, page: Int) {
        self.searchKeyword = text
        self.centerLat = lat
        self.centerLon = lon
        self.page = page
    }
}
