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
    private var city: Forecast.City

    @Published
    private(set) var isLoading: Bool = false

    @Published
    private(set) var row: Row?

    init(
        city: Forecast.City,
        forecastService: ForecastService = .default
    ) {
        self.city = city
        self.forecastService = forecastService
    }

    func fetchForecast() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let forecast = try await forecastService.fetchForecast(for: city)
            row = .init(forecast: forecast)
        } catch {
            print(error)
        }
    }
}

extension WeatherForecastViewModel {
    struct Row: Hashable {
        struct Weather: Hashable {
            var temperature: Double
            var maxTemperature: Double
            var minTemperature: Double
            var pop: Double
            var description: String
            var iconURL: URL?
            var date: String
        }

        var cityName: String
        var weather: [Weather]
    }
}

extension WeatherForecastViewModel.Row {
    init(forecast: Forecast) {
        self.init(
            cityName: forecast.cityName,
            weather: forecast.weather.map { .init(weather: $0) }
        )
    }
}

extension WeatherForecastViewModel.Row.Weather {
    init(weather: Forecast.Weather) {
        self.init(
            temperature: weather.temperature,
            maxTemperature: weather.maxTemperature,
            minTemperature: weather.minTemperature,
            pop: weather.pop,
            description: weather.description,
            iconURL: .init(string: "https://openweathermap.org/img/wn/\(weather.weatherIcon)@2x.png"),
            date: weather.date
        )
    }
}
