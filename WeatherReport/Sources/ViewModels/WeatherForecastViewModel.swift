//
//  WeatherForecastViewModel.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

@MainActor
final class WeatherForecastViewModel: ObservableObject {
    private let forecastService: ForecastService
    private let forecastDataManager: ForecastDataManager
    private var city: Forecast.City

    @Published
    private(set) var isLoading: Bool = false

    @Published
    private(set) var row: Row?

    @Published
    var alert: Alert = .init()

    @Published
    var error: Error?

    private var maxRetryCount = 3

    init(
        city: Forecast.City,
        forecastService: ForecastService = .default,
        forecastDataManager: ForecastDataManager = .shared
    ) {
        self.city = city
        self.forecastService = forecastService
        self.forecastDataManager = forecastDataManager
    }

    func fetchForecast() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let cachedForecast = forecastDataManager.fetchCachedForecast(cityName: city.name ?? "") {
                row = .init(forecast: cachedForecast)
                isLoading = false
                return
            }
            let forecast = try await forecastService.fetchForecast(for: city)
            row = .init(forecast: forecast)
        } catch {
            if maxRetryCount > 0 {
                maxRetryCount -= 1
                self.error = error
            } else {
                alert.retryLimit = true
            }
        }
    }
}

extension WeatherForecastViewModel {
    struct Row: Hashable {
        struct Weather: Hashable {
            var temperature: Int
            var maxTemperature: Int
            var minTemperature: Int
            var pop: Int
            var description: String
            var iconURL: URL?
            var date: String
        }

        var cityName: String
        var lat: Double
        var lon: Double
        var weather: [Weather]
    }

    struct Alert: Hashable {
        var retryLimit: Bool = false
    }
}

extension WeatherForecastViewModel.Row {
    init(forecast: Forecast) {
        self.init(
            cityName: forecast.displayCityName,
            lat: forecast.lat,
            lon: forecast.lon,
            weather: forecast.weather.map { .init(weather: $0) }
        )
    }
}

extension WeatherForecastViewModel.Row.Weather {
    init(weather: Forecast.Weather) {
        self.init(
            temperature: Int(weather.temperature),
            maxTemperature: Int(weather.maxTemperature),
            minTemperature: Int(weather.minTemperature),
            pop: Int(weather.pop * 100),
            description: weather.description,
            iconURL: .init(string: "https://openweathermap.org/img/wn/\(weather.weatherIcon)@2x.png"),
            date: weather.date.convertDateFormat(inputFormat: "yyyy-MM-dd HH:mm:ss", outputFormat: "MM月dd日 HH:mm") ?? ""
        )
    }
}

extension Array where Element == WeatherForecastViewModel.Row.Weather {
    /// "MM月dd日"ごとにグループ化
    func groupedByDay() -> [(date: String, weathers: [Element])] {
        let groups = Dictionary(grouping: self) { weather in
            weather.date.components(separatedBy: " ").first ?? weather.date
        }
        // 日付順にソート
        return groups
            .map { key, value in (date: key, weathers: value) }
            .sorted { $0.date < $1.date }
    }
}
