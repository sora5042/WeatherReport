//
//  MockForecastDataManager.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/20.
//

import Foundation

@testable import WeatherReport

final class MockForecastDataManager: ForecastDataManaging {
    var cachedForecasts: [String: Forecast] = [:]

    func saveForecast(_ forecast: Forecast, city: Forecast.City) async {
        cachedForecasts[city.name ?? ""] = forecast
    }

    func fetchCachedForecast(cityName: String) -> Forecast? {
        cachedForecasts[cityName]
    }
}
