//
//  Constant.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/11/24.
//

import Foundation

enum Constant {
    static var tmapBaseURL: String {
        let urlString = Bundle.main.object(forInfoDictionaryKey: "TMapBaseURL") as? String
        return "https://\(urlString ?? "")"
    }
    
    static var tApiAppKey: String {
        let appKey = Bundle.main.object(forInfoDictionaryKey: "TApiAppKey") as? String
        return appKey ?? ""
    }
}
