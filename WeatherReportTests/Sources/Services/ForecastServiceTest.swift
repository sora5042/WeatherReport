//
//  ForecastServiceTest.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/20.
//

import Foundation

@testable import WeatherReport

struct ForecastServiceTest: ForecastService {
    var fetchForecastHandler: ((_ city: Forecast.City) async throws -> Forecast)?

    func fetchForecast(for city: Forecast.City) async throws -> Forecast {
        if let handler = fetchForecastHandler {
            return try await handler(city)
        } else {
            fatalError("fetchForecast is not set")
        }
    }
}
