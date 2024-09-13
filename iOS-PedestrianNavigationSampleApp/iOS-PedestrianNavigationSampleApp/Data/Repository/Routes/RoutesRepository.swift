//
//  RoutesRepository.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation
import Combine

protocol RoutesRepositoryProtocol {
    func fetchRoutes(_ parameter: RoutesDTO.RequestDTO.PostRoutes) -> AnyPublisher<RoutesDTO.ResponseDTO.PostRoutes, DataError>
}

final class RoutesRepository: URLSessionManager<RoutesTarget>, RoutesRepositoryProtocol {
    func fetchRoutes(_ parameter: RoutesDTO.RequestDTO.PostRoutes) -> AnyPublisher<RoutesDTO.ResponseDTO.PostRoutes, DataError> {
        return self.fetch(target: .postRoutes(parameter), responseData: RoutesDTO.ResponseDTO.PostRoutes.self)
    }
}
