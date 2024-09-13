//
//  RoutesResponseDTO.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation

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
            case line([Double])
            case point([[Double]])
        }
        
        enum CodingKeys: CodingKey {
            case type
            case coordinates
        }
        
        init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<RoutesDTO.ResponseDTO.Geometry.CodingKeys> = try decoder.container(keyedBy: RoutesDTO.ResponseDTO.Geometry.CodingKeys.self)
            self.type = try container.decode(String.self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.type)
            
            if let line = try? container.decode([Double].self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.coordinates) {
                self.coordinates = .line(line)
            } else if let point = try? container.decode([[Double]].self, forKey: RoutesDTO.ResponseDTO.Geometry.CodingKeys.coordinates) {
                self.coordinates = .point(point)
            } else {
                throw DecodingError.typeMismatch(Coordinates.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Invalid type for coordinates"))
            }
        }
    }
    
    struct PointProperties: Decodable {
        let totalDistance: Int?
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
