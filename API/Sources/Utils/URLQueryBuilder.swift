//
//  URLQueryBuilder.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import Foundation

private protocol URLQueryRespresentable {}

extension Int: URLQueryRespresentable {}

extension Double: URLQueryRespresentable {}

extension String: URLQueryRespresentable {}

public class URLQueryBuilder {
    public private(set) var dictionary: [String: Any]

    public init(dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public init(encodable: some Encodable) {
        dictionary = try! encodable.convertToDictionary()
    }

    public func build() -> String {
        return dictionary.compactMap { key, value in
            if let stringValue = value as? String {
                return "\(key)=\(encode(stringValue))"
            } else if let intValue = value as? Int {
                return "\(key)=\(intValue)"
            } else if let doubleValue = value as? Double {
                return "\(key)=\(doubleValue)"
            } else {
                return nil
            }
        }
        .joined(separator: "&")
    }

    private func encode(_ string: String) -> String {
        let allowedCharacterSet = CharacterSet.urlQueryAllowed
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
