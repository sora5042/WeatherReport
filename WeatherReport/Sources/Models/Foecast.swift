//
//  Foecast.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

struct Forecast: Hashable {
    struct Weather: Hashable {
        var date: String
        var temperature: Double
        var maxTemperature: Double
        var minTemperature: Double
        var humidity: Int
        var description: String
        var weatherIcon: String
        var windSpeed: Double
        var windDeg: Int
        var pop: Double
        var pod: String
    }

    var weather: [Weather]
    var city: City?
    var cityName: String
    var lat: Double
    var lon: Double

    enum City: CaseIterable, Hashable {
        case tokyo
        case osaka
        case hyogo
        case oita
        case hokkaido
        case current(lat: Double, lon: Double)

        static var allCases: [City] {
            return [
                .tokyo,
                .osaka,
                .hyogo,
                .oita,
                .hokkaido,
                .current(lat: 0, lon: 0),
            ]
        }

        var name: String? {
            switch self {
            case .tokyo:
                return "Tokyo"
            case .osaka:
                return "Osaka"
            case .hyogo:
                return "Hyogo"
            case .oita:
                return "Oita"
            case .hokkaido:
                return "Hokkaido"
            case .current:
                return nil
            }
        }
    }
}
