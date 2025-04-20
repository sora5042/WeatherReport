//
//  LocationManager.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/16.
//

import CoreLocation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()

    @Published
    var currentLocation: CLLocation?
    @Published
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private var updates: CLLocationUpdate.Updates?
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Error>?

    override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }

    func startTracking() async throws {
        updates = CLLocationUpdate.liveUpdates(.fitness)

        for try await update in updates! {
            guard let location = update.location else { continue }
            currentLocation = location

            if #available(iOS 18, *) {
                if update.stationary {
                    break
                }
            } else if #available(iOS 17, *) {
                if update.isStationary {
                    break
                }
            }
        }
    }

    func requestAuthorization() async -> CLAuthorizationStatus {
        manager.requestWhenInUseAuthorization()
        while manager.authorizationStatus == .notDetermined {
            await Task.yield()
        }
        return manager.authorizationStatus
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            self?.authorizationStatus = manager.authorizationStatus
        }
    }
}
