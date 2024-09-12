//
//  String+.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation

extension String {
    func utf8Encode() -> String? {
        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}
