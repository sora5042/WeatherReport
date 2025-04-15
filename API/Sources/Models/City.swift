//
//  City.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

public enum City: String, Codable, CaseIterable, Hashable {
    case tokyo = "Tokyo"
    case osaka = "Osaka"
    case hyogo = "Hyogo"
    case oita = "Oita"
    case hokkaido = "Hokkaido"
}
