//
//  HomeViewModel.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let dataStore: SecuredDataStore

    @Published
    var navigation: Navigation?

    init(
        dataStore: SecuredDataStore = SharedData.shared
    ) {
        self.dataStore = dataStore
        dataStore.apiKey = "afd634bbf1c76e0a9b43c2f330fb04ac"
    }

    func selectedCity(_ city: Forecast.City) {
        navigation = .weatherForecast(city)
    }
}

extension HomeViewModel {
    enum Navigation: Hashable {
        case weatherForecast(Forecast.City)
    }
}
