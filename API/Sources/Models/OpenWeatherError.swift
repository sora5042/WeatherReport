//
//  OpenWeatherError.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

public struct OpenWeatherError: Decodable {
    public var cod: Int
    public var message: String
}
