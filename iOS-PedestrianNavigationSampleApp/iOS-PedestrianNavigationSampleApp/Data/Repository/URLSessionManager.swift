//
//  URLSessionManager.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import Combine

enum URLSessionError: Error {
    case invalidStatusCode
}

class URLSessionManager<T: TargetType> {
    func fetch<M: Decodable> (target: T,
                              responseData: M.Type) -> AnyPublisher<M, DataError> {
        return URLSession.shared
            .dataTaskPublisher(for: target.asURLRequest())
            .tryMap {
                if let httpResponse = $0.response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    if !((200..<300) ~= statusCode) {
                        throw URLSessionError.invalidStatusCode
                    }
                }
                return $0.data
            }
            .decode(type: responseData, decoder: JSONDecoder())
            .mapError {
                .error($0)
            }
            .eraseToAnyPublisher()
        
    }
}
