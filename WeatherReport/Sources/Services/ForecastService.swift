//
//  ForecastService.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import API
import Foundation

protocol ForecastService {
    func fetchForecast(for city: Forecast.City) async throws -> Forecast
}

struct DefaultForecastService: ForecastService {
    var forecastAPI: ForecastAPI = .init(apiClient: .init())
    private let dataStore: SecuredDataStore = SharedData.shared

    func fetchForecast(for city: Forecast.City) async throws -> Forecast {
        switch city {
        case let .current(latitude, longitude):
            let response = try await forecastAPI.get(.init(appid: dataStore.apiKey, lat: latitude, lon: longitude))
            return .init(forecast: response)
        default:
            let response = try await forecastAPI.get(.init(appid: dataStore.apiKey, q: .init(rawValue: city.name ?? "")))
            return .init(forecast: response)
        }
    }
}

extension Forecast.City {
    init(city: API.City) {
        switch city {
        case .tokyo:
            self = .tokyo
        case .osaka:
            self = .osaka
        case .hyogo:
            self = .hyogo
        case .oita:
            self = .oita
        case .hokkaido:
            self = .hokkaido
        @unknown default:
            fatalError()
        }
    }
}

extension Forecast {
    init(forecast: API.Forecast) {
        self.init(
            weather: forecast.list.map { .init(list: $0) },
            cityName: forecast.city.name,
            lat: forecast.city.coord.lat,
            lon: forecast.city.coord.lon
        )
    }
}

extension Forecast.Weather {
    init(list: API.Forecast.List) {
        self.init(
            date: list.dt_txt,
            temperature: list.main.temp,
            maxTemperature: list.main.temp_max,
            minTemperature: list.main.temp_min,
            humidity: list.main.humidity,
            description: list.weather.first?.description ?? "",
            weatherIcon: list.weather.first?.icon ?? "",
            windSpeed: list.wind.speed,
            windDeg: list.wind.deg,
            pop: list.pop,
            pod: list.sys.pod
        )
    }
}

extension ForecastService where Self == DefaultForecastService {
    static var `default`: ForecastService { DefaultForecastService() }
}
