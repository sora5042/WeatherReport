//
//  CodableExtensions.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import Foundation

public extension Encodable {
    func convertToDictionary() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: JSONEncoder().encode(self), options: []) as! [String: Any]
    }
}
