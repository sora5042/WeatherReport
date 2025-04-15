//
//  SwiftUIExtension.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import SwiftUI

extension View {
    @MainActor
    func loading(isPresented: Bool, dimmed: Bool = false) -> some View {
        disabled(isPresented, dimmed: dimmed)
            .overlay {
                if isPresented {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
    }
}

extension View {
    @ViewBuilder
    func hidden(_ where: @autoclosure () -> Bool) -> some View {
        opacity(`where`() ? 0 : 1)
            .disabled(`where`())
    }

    func disabled(_ disabled: Bool, dimmed: Bool, color: Color? = nil) -> some View {
        self.disabled(disabled)
            .dimmed(disabled && dimmed, color: color)
    }

    @ViewBuilder
    func dimmed(_ dimmed: Bool, color: Color? = nil) -> some View {
        if let color {
            opacity(dimmed ? 0.7 : 1)
                .background(dimmed ? color.opacity(0.2) : Color.white)
        } else {
            opacity(dimmed ? 0.3 : 1)
        }
    }
}

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
