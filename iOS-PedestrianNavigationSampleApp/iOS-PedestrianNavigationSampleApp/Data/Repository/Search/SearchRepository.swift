//
//  SearchRepository.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import Combine

protocol SearchRepositoryProtocol {
    func fetchTotal(_ parameter: SearchDTO.RequestDTO.TotalSearchRequest) -> AnyPublisher<SearchDTO.ResponseDTO.Result, DataError>
}

final class SearchRepository: URLSessionManager<SearchTarget>, SearchRepositoryProtocol {
    func fetchTotal(_ parameter: SearchDTO.RequestDTO.TotalSearchRequest) -> AnyPublisher<SearchDTO.ResponseDTO.Result, DataError> {
        return self.fetch(target: .getTotal(parameter), responseData: SearchDTO.ResponseDTO.Result.self)
    }
}
