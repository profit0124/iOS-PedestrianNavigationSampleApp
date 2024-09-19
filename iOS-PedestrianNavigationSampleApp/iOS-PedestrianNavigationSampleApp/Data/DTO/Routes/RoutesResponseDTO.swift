//
//  RoutesResponseDTO.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation
import MapKit

extension RoutesDTO.ResponseDTO {
    struct PostRoutes: Decodable {
        let type: String
        let features: [Feature]
    }
    
    struct Feature: Decodable {
        let type: String
        let geometry: Geometry
        let properties: Properties
        
        enum Properties: Decodable {
            case line(LinePorperties)
            case point(PointProperties)
        }
        
        enum CodingKeys: String, CodingKey {
            case type, geometry, properties
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<RoutesDTO.ResponseDTO.Feature.CodingKeys> = try decoder.container(keyedBy: RoutesDTO.ResponseDTO.Feature.CodingKeys.self)
            self.type = try container.decode(String.self, forKey: RoutesDTO.ResponseDTO.Feature.CodingKeys.type)
            self.geometry = try container.decode(RoutesDTO.ResponseDTO.Geometry.self, forKey: RoutesDTO.ResponseDTO.Feature.CodingKeys.geometry)
            if let lineProperties = try? container.decode(LinePorperties.self, forKey: RoutesDTO.ResponseDTO.Feature.CodingKeys.properties) {
                self.properties = .line(lineProperties)
            } else if let pointProperties = try? container.decode(PointProperties.self, forKey: RoutesDTO.ResponseDTO.Feature.CodingKeys.properties) {
                self.properties = .point(pointProperties)
            } else {
                throw DecodingError.typeMismatch(Properties.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type for Properties"))
            }
        }
        
    }
    
    struct Geometry: Decodable {
        let type: String
        let coordinates: Coordinates
        
        enum Coordinates {
            case point([Double])
            case line([[Double]])
        }
        
        enum CodingKeys: CodingKey {
            case type
            case coordinates
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<RoutesDTO.ResponseDTO.Geometry.CodingKeys> = try decoder.container(keyedBy: RoutesDTO.ResponseDTO.Geometry.CodingKeys.self)
            self.type = try container.decode(String.self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.type)
            
            if let point = try? container.decode([Double].self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.coordinates) {
                self.coordinates = .point(point)
            } else if let line = try? container.decode([[Double]].self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.coordinates) {
                self.coordinates = .line(line)
            } else {
                throw DecodingError.typeMismatch(Coordinates.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type for coordinates"))
            }
        }
    }
    
    struct PointProperties: Decodable {
        /// 단위 m
        let totalDistance: Int?
        /// 단위 초
        let totalTime: Int?
        let index: Int
        let pointIndex: Int
        let name: String
        let description: String
        let direction: String
        let nearPoiName: String
        let nearPoiX: String
        let nearPoiY: String
        let intersectionName: String
        let facilityType: String
        let facilityName: String
        let turnType: Int
        let pointType: String
    }
    
    struct LinePorperties: Decodable {
        let index: Int
        let lineIndex: Int
        let name: String
        let description: String
        let distance: Int
        let time: Int
        let roadType: Int
        let categoryRoadType: Int
        let facilityType: String
        let facilityName: String
    }
}

extension RoutesDTO.ResponseDTO.PostRoutes {
    func toSearchDetailModel() -> SearchDetailViewModel.State? {
        var totalDistance = 0
        var totalTime = 0
        var routes: [NavigationModel] = []
        var id = -1
        var name = ""
        var description = ""
        var pointCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var lineModels: [MKPolyLineModel] = []
        /// Point type 의 Feature 로 시작 <-> Point Type 의 Feature로 종료
        /// 각 Point type 의 feature 사이에 Line Type 의 Feature 가 여러개 끼어있음
        /// 
        self.features.forEach {
            switch $0.properties {
            case .point(let pointProperties):
                if let distance = pointProperties.totalDistance,
                   let time = pointProperties.totalTime {
                    totalDistance = distance
                    totalTime = time
                }
                
                if id != -1 {
                    routes.append(.init(
                        id: id,
                        name: name,
                        description: description,
                        pointCoordinate: pointCoordinate,
                        lineModels: lineModels))
                    lineModels = []
                }
                
                id = pointProperties.pointIndex
                name = pointProperties.name
                description = pointProperties.description
                
                switch $0.geometry.coordinates {
                case .point(let array):
                    pointCoordinate = CLLocationCoordinate2D(latitude: array[1], longitude: array[0])
                case .line:
                    break
                }
                
            case .line(let linePorperties):
                switch $0.geometry.coordinates {
                case .point:
                    break
                case .line(let array):
                    let coordinate = array.map {
                        CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                    }
                    let lineModel = MKPolyLineModel(id: linePorperties.lineIndex, name: linePorperties.name, description: linePorperties.description, cooridnates: coordinate)
                    lineModels.append(lineModel)
                }
            }
        }
        
        routes.append(.init(id: id, name: name, description: description, pointCoordinate: pointCoordinate, lineModels: []))
        
        return .init(
            totalDistance: totalDistance,
            totalTime: totalTime,
            routes: routes
        )
    }
    
    
    
}
