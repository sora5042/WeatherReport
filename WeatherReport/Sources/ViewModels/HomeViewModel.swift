//
//  HomeViewModel.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    private let dataStore: SecuredDataStore
    private let locationManager = LocationManager()

    @Published
    var navigation: Navigation?

    @Published
    var alert: Alert = .init()

    @Published
    var error: Error?

    private var currentLocation: CLLocation?

    private var cancellables = Set<AnyCancellable>()

    init(
        dataStore: SecuredDataStore = SharedData.shared
    ) {
        self.dataStore = dataStore
        if dataStore.apiKey == nil || dataStore.apiKey?.isEmpty == true {
            dataStore.apiKey = "afd634bbf1c76e0a9b43c2f330fb04ac"
        }

        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
    }

    func selectedCity(_ city: Forecast.City) async {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            await fetchCurrentLocation()
            return
        case .denied, .restricted:
            alert.denied = true
            return
        case .authorizedWhenInUse, .authorizedAlways:
            var city = city
            if city == .current(lat: 0, lon: 0) {
                city = .current(
                    lat: currentLocation?.coordinate.latitude ?? 0,
                    lon: currentLocation?.coordinate.longitude ?? 0
                )
            }
            navigation = .weatherForecast(city)
        @unknown default:
            fatalError(#function)
        }
    }

    func fetchCurrentLocation() async {
        let status = await locationManager.requestAuthorization()
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            error = NSError(domain: "Location", code: 1, userInfo: [NSLocalizedDescriptionKey: "位置情報の利用が許可されていません"])
            return
        }

        do {
            try await locationManager.startTracking()
        } catch {
            self.error = error
        }
    }
}

extension HomeViewModel {
    enum Navigation: Hashable {
        case weatherForecast(Forecast.City)
    }

    struct Alert: Hashable {
        var denied: Bool = false
    }
}
