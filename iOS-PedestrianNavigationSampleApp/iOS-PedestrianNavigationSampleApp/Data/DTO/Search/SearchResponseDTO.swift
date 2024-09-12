//
//  ResponseDTO.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

extension SearchDTO.ResponseDTO {
    struct Result: Decodable {
        let searchPoiInfo: SearchPoiInfo
    }
    
    struct SearchPoiInfo: Decodable {
        let totalCount: String
        let count: String
        let page: String
        let pois: Pois
    }
    
    struct Pois: Decodable {
        let poi: [Poi]
    }
    
    struct Poi: Decodable {
        let id: String
        let pkey: String?
        let name: String?
        let telNo: String?
        let noorLat: String?
        let noorLon: String?
        let upperAddrName: String?
        let middleAddrName: String?
        let lowerAddrName: String?
        let detailAddrName: String?
        let firstNo: String?
        let secondNo: String?
        let roadName: String?
        let firstBuildNo: String?
        let secondBuildNo: String?
    }
}

extension SearchDTO.ResponseDTO.Poi {
    func toModel() -> SearchResultModel {
        let pkey = self.pkey ?? UUID().uuidString
        let name = self.name ?? "등록된 이름 없음"
        let tel = self.telNo ?? "등록된 전화번호 없음"
        let lat = Double(self.noorLat ?? "37.5999") ?? 37.5999
        let lon = Double(self.noorLon ?? "127.0453") ?? 127.0453
        let newAddres = "\(self.upperAddrName ?? "") \(self.middleAddrName ?? "") \(self.roadName ?? "") \(self.firstBuildNo ?? "")-\(self.secondBuildNo ?? "")"
        let oldAddres = "\(self.upperAddrName ?? "") \(self.middleAddrName ?? "") \(self.lowerAddrName ?? "") \(self.detailAddrName ?? "") \(self.firstNo ?? "")-\(self.secondNo ?? "")"
        
        return SearchResultModel(id: self.id, pKey: pkey, name: name, tel: tel, lat: lat, long: lon, newAddress: newAddres, oldAddress: oldAddres)
        
    }
}
