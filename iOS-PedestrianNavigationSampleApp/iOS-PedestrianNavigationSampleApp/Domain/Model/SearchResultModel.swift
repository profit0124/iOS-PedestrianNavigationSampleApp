//
//  SearchResultModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

struct SearchResultModel: Identifiable, Equatable, Hashable {
    let id: String
    let pKey: String
    let name: String
    let tel: String
    let lat: Double
    let long: Double
    let newAddress: String
    let oldAddress: String
}

extension SearchResultModel {
    static let mock1 = SearchResultModel(
        id: UUID().uuidString,
        pKey: UUID().uuidString,
        name: "검색결과 1",
        tel: "02-111-1111",
        lat: 37.6018,
        long: 127.0433,
        newAddress: "서울특별시 뭐시기 무슨로 1",
        oldAddress: "서울특별시 북구 뭔동 23-2")
    
    static let mock2 = SearchResultModel(
        id: UUID().uuidString,
        pKey: UUID().uuidString,
        name: "검색결과 2",
        tel: "02-222-2222",
        lat: 37.6000,
        long: 127.0451,
        newAddress: "서울특별시 뭐시기 무슨로 1",
        oldAddress: "서울특별시 북구 뭔동 23-2")
    
    static let mock3 = SearchResultModel(
        id: UUID().uuidString,
        pKey: UUID().uuidString,
        name: "검색결과 3",
        tel: "02-333-3333",
        lat: 37.6046,
        long: 127.0454,
        newAddress: "서울특별시 뭐시기 무슨로 1",
        oldAddress: "서울특별시 북구 뭔동 23-2")
}
