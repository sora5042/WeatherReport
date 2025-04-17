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
        switch city {
        case .current:
            return "current_\(lat.formatted(.number))_\(lon.formatted(.number))"
        default:
            return "\(city.name?.lowercased() ?? "")_\(lat.formatted(.number))_\(lon.formatted(.number))"
        }
    }
}

@Model
final class WeatherEntity {
    @Attribute(.unique) var timestamp: Date
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

    @Relationship(inverse: \ForecastEntity.weathers)
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        timestamp = formatter.date(from: date) ?? Date()
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
