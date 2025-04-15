//
//  WeatherReportApp.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import SwiftUI

@main
struct WeatherReportApp: App {
    @StateObject
    private var navigator: Navigator = .init()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigator.path) {
                HomeView()
            }
            .navigationViewStyle(.stack)
            .environmentObject(navigator)
        }
    }
}

extension WeatherReportApp {
    @MainActor
    final class Navigator: ObservableObject {
        @Published
        fileprivate var path: NavigationPath = .init()

        func popToRootView() {
            path = .init()
        }

        func pop() {
            path.removeLast()
        }

        func push<Navigation: Hashable>(_ navigation: Navigation) {
            path.append(navigation)
        }
    }
}
