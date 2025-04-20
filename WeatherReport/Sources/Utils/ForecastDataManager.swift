//
//  ForecastDataManager.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/16.
//

import Foundation
import SwiftData

protocol ForecastDataManaging {
    func saveForecast(_ forecast: Forecast, city: Forecast.City) async
    func fetchCachedForecast(cityName: String) -> Forecast?
}

final class ForecastDataManager: ForecastDataManaging {
    static let shared = ForecastDataManager()

    let container: ModelContainer
    private let context: ModelContext

    init() {
        do {
            container = try ModelContainer(
                for: ForecastEntity.self,
                WeatherEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
            context = ModelContext(container)
        } catch {
            fatalError("SwiftDataコンテナの初期化に失敗しました: \(error)")
        }
    }

    @MainActor
    func saveForecast(_ forecast: Forecast, city: Forecast.City) async {
        deleteExistingData(for: city.name ?? "現在地")

        let forecastEntity = ForecastEntity(forecast: forecast, city: city)
        context.insert(forecastEntity)

        do {
            try context.save()
        } catch {
            print("保存エラー: \(error)")
        }
    }

    @MainActor
    private func deleteExistingData(for cityName: String) {
        let predicate = #Predicate<ForecastEntity> { $0.cityName == cityName }
        let descriptor = FetchDescriptor<ForecastEntity>(predicate: predicate)

        do {
            let results = try context.fetch(descriptor)
            results.forEach { context.delete($0) }
        } catch {
            print("削除エラー: \(error)")
        }
    }

    func fetchCachedForecast(cityName: String) -> Forecast? {
        let currentDate = Date()

        let predicate = #Predicate<ForecastEntity> {
            $0.cityName == cityName && $0.expirationDate > currentDate
        }

        var descriptor = FetchDescriptor<ForecastEntity>()
        descriptor.predicate = predicate

        guard let entity = try? context.fetch(descriptor).first else {
            return nil
        }

        return .init(entity: entity)
    }
}
