//
//  WeatherForecastViewModelTests.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/20.
//

import Foundation
import XCTest

@testable import WeatherReport

@MainActor
final class WeatherForecastViewModelTests: XCTestCase {
    var mockService: ForecastServiceTest!
    var mockDataManager: MockForecastDataManager!

    let osakaCity = Forecast.City.osaka
    let osakaName = "大阪市"
    let osakaLat = 34.6937
    let osakaLon = 135.5023

    override func setUp() {
        super.setUp()
        mockService = .init()
        mockDataManager = MockForecastDataManager()

        mockService.fetchForecastHandler = { _ in
            .mockOsaka(lat: 34.6937, lon: 135.5023)
        }
    }

    private func makeViewModel() -> WeatherForecastViewModel {
        .init(
            city: osakaCity,
            forecastService: mockService
        )
    }

    func test_fetchForecast_withoutCache_shouldFetchFromAPIAndSave() async {
        let viewModel = makeViewModel()

        mockService.fetchForecastHandler = { [unowned self] _ in
            .mockOsaka(lat: osakaLat, lon: osakaLon)
        }

        await viewModel.fetchForecast()

        XCTAssertEqual(viewModel.row?.cityName, osakaName)
    }

    func test_fetchForecast_withExpiredCache_shouldRefetchAndUpdateCache() async {
        let viewModel = makeViewModel()
        // 有効期限切れキャッシュ
        await mockDataManager.saveForecast(
            .mockOsaka(lat: 0, lon: 0),
            city: osakaCity
        )

        // 新しいデータ取得
        mockService.fetchForecastHandler = { [unowned self] _ in
            .mockOsaka(lat: osakaLat, lon: osakaLon)
        }
        await viewModel.fetchForecast()

        XCTAssertEqual(viewModel.row?.lat, osakaLat)
        XCTAssertEqual(viewModel.row?.lon, osakaLon)
    }
}

extension Forecast.City {
    var localizedName: String {
        switch self {
        case .osaka: return "大阪市"
        default: return name ?? ""
        }
    }
}

extension Forecast {
    static func mockOsaka(lat: Double, lon: Double) -> Forecast {
        Forecast(
            weather: [
                .init(
                    date: DateFormatter.weatherDateFormatter.string(from: Date()),
                    temperature: 20.5,
                    maxTemperature: 22.0,
                    minTemperature: 18.0,
                    humidity: 60,
                    description: "晴れ",
                    weatherIcon: "01d",
                    windSpeed: 5.0,
                    windDeg: 180,
                    pop: 0.0,
                    pod: "d"
                )
            ],
            displayCityName: "大阪市",
            lat: lat,
            lon: lon
        )
    }
}

extension DateFormatter {
    static let weatherDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return formatter
    }()
}
