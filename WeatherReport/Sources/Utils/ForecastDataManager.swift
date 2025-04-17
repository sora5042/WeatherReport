//
//  ForecastDataManager.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/16.
//

import Foundation
import SwiftData

final class ForecastDataManager {
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
        } catch {}
    }

    @MainActor
    private func deleteExistingData(for cityName: String) {
        let predicate = #Predicate<ForecastEntity> { $0.cityName == cityName }
        let descriptor = FetchDescriptor<ForecastEntity>(predicate: predicate)

        do {
            let results = try context.fetch(descriptor)
            results.forEach { context.delete($0) }
        } catch {}
    }

    @MainActor
    func fetchCachedForecast(cityName: String) -> Forecast? {
        let currentDate = Date()

        let predicate = #Predicate<ForecastEntity> {
            $0.cityName == cityName && $0.expirationDate > currentDate
        }

        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.expirationDate, order: .reverse)]
        )

        guard let entity = try? context.fetch(descriptor).first else {
            return nil
        }

        return .init(entity: entity)
    }
}
