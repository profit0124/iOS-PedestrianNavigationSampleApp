//
//  Encodable+.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionary = jsonData as? [String: Any]
        else { return [:] }
        return dictionary
    }
    
    func getURLComponent(_ urlString: String) -> URLComponents? {
        var component = URLComponents(string: urlString)
        if component != nil {
            let query = self.toDictionary()
            let queryItems = query.map{ URLQueryItem(name: $0.key, value: "\($0.value)") }
                component?.queryItems = queryItems
        }
        return component
    }
    
    func getBodyData() -> Data? {
        if let parameterArray = self as? [AnyObject] {
            let dictArray = parameterArray.compactMap{
                if let param = $0 as? Encodable {
                    return param.toDictionary()
                } else {
                    return nil
                }
            }
            return try? JSONSerialization.data(withJSONObject: dictArray, options: [])
        } else {
            let parameter = self.toDictionary()
            return try? JSONSerialization.data(withJSONObject: parameter, options: [])
        }
    }
}
