//
//  ForecastEntity.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/16.
//

import Foundation
import SwiftData

@Model
final class ForecastEntity {
    @Attribute(.unique) var id: String
    var cityName: String
    var displayCityName: String
    var lat: Double
    var lon: Double
    var expirationDate: Date
    var weathers: [WeatherEntity]

    init(city: Forecast.City, displayCityName: String, lat: Double, lon: Double, weathers: [WeatherEntity]) {
        id = Self.generateIdentifier(city: city, lat: lat, lon: lon)
        cityName = city.name ?? "現在地"
        self.displayCityName = displayCityName
        self.lat = lat
        self.lon = lon
        expirationDate = Date().nextMidnight
        self.weathers = weathers
    }

    private static func generateIdentifier(city: Forecast.City, lat: Double, lon: Double) -> String {
        let latStr = String(format: "%.6f", lat)
        let lonStr = String(format: "%.6f", lon)

        switch city {
        case .current:
            return "current_\(latStr)_\(lonStr)"
        default:
            let cityName = city.name?.lowercased() ?? "unknown"
            return "\(cityName)_\(latStr)_\(lonStr)"
        }
    }
}

@Model
final class WeatherEntity {
    var date: String
    var temperature: Double
    var maxTemperature: Double
    var minTemperature: Double
    var humidity: Int
    var weatherDescription: String
    var iconCode: String
    var windSpeed: Double
    var windDeg: Int
    var precipitation: Double
    var pod: String

    @Relationship(deleteRule: .cascade, inverse: \ForecastEntity.weathers)
    var forecast: ForecastEntity?

    init(
        date: String,
        temperature: Double,
        maxTemperature: Double,
        minTemperature: Double,
        humidity: Int,
        description: String,
        iconCode: String,
        windSpeed: Double,
        windDeg: Int,
        pop: Double,
        pod: String
    ) {
        self.date = date
        self.temperature = temperature
        self.maxTemperature = maxTemperature
        self.minTemperature = minTemperature
        self.humidity = humidity
        weatherDescription = description
        self.iconCode = iconCode
        self.windSpeed = windSpeed
        self.windDeg = windDeg
        precipitation = pop
        self.pod = pod
    }
}

extension Date {
    var nextMidnight: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar.nextDate(
            after: self,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime,
            repeatedTimePolicy: .first,
            direction: .forward
        ) ?? addingTimeInterval(86400)
    }
}
