//
//  SwiftUIExtension.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import SwiftUI

extension View {
    func navigatorDestination<Navigation: Hashable, Destination: View>(
        _ navigation: Binding<Navigation?>,
        @ViewBuilder destination: @escaping (Navigation) -> Destination
    ) -> some View {
        navigationDestination(for: Navigation.self, destination: destination)
            .modifier(NavigationDestination(navigation: navigation))
    }
}

private struct NavigationDestination<Navigation: Hashable>: ViewModifier {
    @Binding
    var navigation: Navigation?

    @EnvironmentObject
    private var navigator: WeatherReportApp.Navigator

    func body(content: Content) -> some View {
        content
            .onChange(of: navigation) { value in
                if let value {
                    navigator.push(value)
                    navigation = nil
                }
            }
    }
}
