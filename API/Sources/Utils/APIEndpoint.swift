//
//  APIEndpoint.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

public protocol APIEndpoint {
    var apiClient: APIClient { get }
    var path: String { get }
}
