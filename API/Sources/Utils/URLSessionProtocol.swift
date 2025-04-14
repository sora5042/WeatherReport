//
//  URLSessionProtocol.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
