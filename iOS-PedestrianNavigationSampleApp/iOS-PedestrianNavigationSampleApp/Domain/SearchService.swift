//
//  SearchService.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import Combine

protocol SearchServiceType {
    func fetch(_ text: String) -> AnyPublisher<[SearchResultModel], ServiceError>
}


final class SearchService: SearchServiceType {
    
    let locationManager: LocationManager
    let searchRepository: SearchRepositoryProtocol
    
    init() {
        self.locationManager = LocationManager()
        self.searchRepository = SearchRepository()
    }
    
    /// 요청이 들어오면 LocationManager 를 통해 현재 위치 확인
    /// 현재 위치값이 들어오면 SearchRepository 를 통해 API 에 값 확인
    /// 위치값을 불러오는 것이 실패한다면 Error 발생
    /// Repository의 응답이 제대로 들어온다면 map 을 통해 Model 로 변경
    /// 최종적으로 Error 가 발생하게 된다면 ServiceError 로 전환
    func fetch(_ text: String) -> AnyPublisher<[SearchResultModel], ServiceError> {
        return locationManager.fetchLocation()
            .flatMap { [weak self] in
                if let self {
                    let coordinator = $0
                    return self.searchRepository.fetchTotal(.init(searchKeyword: text, centerLon: coordinator.longitude, centerLat: coordinator.latitude, page: 1))
                } else {
                    return Future { promise in
                        promise(.failure(DataError.failToGetLocation))
                    }
                    .eraseToAnyPublisher()
                }
            }
            .map {
                $0.searchPoiInfo.pois.poi.map {
                    $0.toModel()
                }
            }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
}

final class StubSearchService: SearchServiceType {
    func fetch(_ text: String) -> AnyPublisher<[SearchResultModel], ServiceError> {
        Just([.mock1, .mock2, .mock3]).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
}
