//
//  HttpMethod.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

enum HttpMethod: String {
    case get
    case post
    case push
    case delete
    
    var upperCase: String {
        self.rawValue.uppercased()
    }
}
