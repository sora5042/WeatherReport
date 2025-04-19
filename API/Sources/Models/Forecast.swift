//
//  Forecast.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

public struct Forecast: Decodable {
    public var cnt: Int
    public var list: [List]
    public var city: City
}

public extension Forecast {
    struct List: Decodable {
        public var dt: Int
        public var main: Main
        public var weather: [Description]
        public var clouds: Clouds
        public var wind: Wind
        public var visibility: Int?
        public var pop: Double
        public var sys: Sys
        public var dt_txt: String
    }

    struct Main: Decodable {
        public var temp: Double
        public var feels_like: Double
        public var temp_min: Double
        public var temp_max: Double
        public var pressure: Int
        public var humidity: Int
    }

    struct Description: Decodable {
        public var id: Int
        public var main: String
        public var description: String
        public var icon: String
    }

    struct Clouds: Decodable {
        public var all: Int
    }

    struct Wind: Decodable {
        public var speed: Double
        public var deg: Int
    }

    struct Sys: Decodable {
        public var pod: String
    }

    struct City: Decodable {
        public var id: Int
        public var name: String
        public var coord: Coord
        public var country: String
        public var timezone: Int
        public var sunrise: Int
        public var sunset: Int
    }

    struct Coord: Decodable {
        public var lon: Double
        public var lat: Double
    }
}
