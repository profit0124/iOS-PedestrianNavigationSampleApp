//
//  TargetType.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

enum RequestParameter {
    case plain
    case query(_ parameter: Encodable)
    case body(_ parameter: Encodable)
    case queryAndBody(_ query: Encodable, _ body: Encodable)
}

enum HttpHeaderField: String {
    case accept = "Accept"
    case appKey = "appKey"
}

enum ContentType: String {
    case json = "application/json"
}

protocol TargetType {
    var baseURL: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var parameter: RequestParameter { get }
    var httpHeaderField: HttpHeaderField? { get }
    
    func asURLRequest() -> URLRequest
}

extension TargetType {
    /// 각 요청별 자동으로 URL Request를 생성하기 위해 사용
    func asURLRequest() -> URLRequest {
        let urlString = baseURL + path
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.upperCase
        
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HttpHeaderField.accept.rawValue)
        
        if let field = httpHeaderField, field == .appKey {
            urlRequest.setValue(Constant.tApiAppKey, forHTTPHeaderField: field.rawValue)
        }
        
        switch parameter {
        case .plain:
            break
            
        case let .query(query):
            if let component = query.getURLComponent(urlString) {
                urlRequest.url = component.url
            }
            
        case let .body(body):
            urlRequest.httpBody = body.getBodyData()
        case let .queryAndBody(query, body):
            if let component = query.getURLComponent(urlString) {
                urlRequest.url = component.url
            }
            urlRequest.httpBody = body.getBodyData()
        }
        
        print(urlRequest)
        return urlRequest
    }
}
