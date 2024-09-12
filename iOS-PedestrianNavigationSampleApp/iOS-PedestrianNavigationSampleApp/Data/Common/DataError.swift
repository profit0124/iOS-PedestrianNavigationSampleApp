//
//  DataError.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

enum DataError: Error {
    case error(Error)
    case failToGetLocation
    case urlError
}
