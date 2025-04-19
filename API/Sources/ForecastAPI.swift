//
//  ForecastAPI.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

public struct ForecastAPI: APIEndpoint {
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public let apiClient: APIClient
    public var path: String = "/forecast"

    public func get(_ param: GetParam) async throws -> Forecast {
        try await apiClient.response(path: path, parameters: param)
    }
}

public extension ForecastAPI {
    struct GetParam: Encodable {
        public init(appid: String? = nil, lat: Double? = nil, lon: Double? = nil, q: City? = nil) {
            self.appid = appid
            self.lat = lat
            self.lon = lon
            self.q = q
        }

        public var appid: String?
        public var lat: Double?
        public var lon: Double?
        public var units: String = "metric"
        public var lang: String = "ja"
        public var q: City?
    }
}
