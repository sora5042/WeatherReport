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
    private let dataManager = ForecastDataManager.shared

    func fetchForecast(for city: Forecast.City) async throws -> Forecast {
        switch city {
        case let .current(latitude, longitude):
            let response = try await forecastAPI.get(.init(appid: dataStore.apiKey, lat: latitude, lon: longitude))
            return .init(forecast: response)
        default:
            let response = try await forecastAPI.get(.init(appid: dataStore.apiKey, q: .init(rawValue: city.name ?? "")))
            let forecast: Forecast = .init(forecast: response)
            Task {
                await dataManager.saveForecast(forecast, city: city)
            }
            return forecast
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
            displayCityName: forecast.city.name,
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

extension ForecastEntity {
    convenience init(forecast: Forecast, city: Forecast.City) {
        let weatherEntities = forecast.weather.map {
            let weather = WeatherEntity(
                date: $0.date,
                temperature: $0.temperature,
                maxTemperature: $0.maxTemperature,
                minTemperature: $0.minTemperature,
                humidity: $0.humidity,
                description: $0.description,
                iconCode: $0.weatherIcon,
                windSpeed: $0.windSpeed,
                windDeg: $0.windDeg,
                pop: $0.pop,
                pod: $0.pod
            )
            return weather
        }

        self.init(
            city: city,
            displayCityName: forecast.displayCityName,
            lat: forecast.lat,
            lon: forecast.lon,
            weathers: weatherEntities
        )
    }
}

extension Forecast {
    init(entity: ForecastEntity) {
        self.init(
            weather: entity.weathers.map(Weather.init).sorted(by: { $0.date < $1.date }),
            city: .current(lat: entity.lat, lon: entity.lon),
            displayCityName: entity.displayCityName,
            lat: entity.lat,
            lon: entity.lon
        )
    }
}

extension Forecast.Weather {
    init(entity: WeatherEntity) {
        self.init(
            date: entity.date,
            temperature: entity.temperature,
            maxTemperature: entity.maxTemperature,
            minTemperature: entity.minTemperature,
            humidity: entity.humidity,
            description: entity.weatherDescription,
            weatherIcon: entity.iconCode,
            windSpeed: entity.windSpeed,
            windDeg: entity.windDeg,
            pop: entity.precipitation,
            pod: entity.pod
        )
    }
}

extension ForecastService where Self == DefaultForecastService {
    static var `default`: ForecastService { DefaultForecastService() }
}
