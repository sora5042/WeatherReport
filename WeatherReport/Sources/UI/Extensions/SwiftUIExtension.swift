//
//  SwiftUIExtension.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import API
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
    @MainActor
    @ViewBuilder
    func alert(_ error: Binding<Error?>, action: @escaping () -> Void = {}) -> some View {
        switch error.wrappedValue {
        case let e as APIError:
            alert(
                isPresented: .init(value: error),
                title: "\(e.localizedDescription)",
                message: "",
                action: action
            )
        case let e?:
            alert(
                isPresented: .init(value: error),
                title: "\(e.localizedDescription)",
                message: "",
                action: action
            )
        default:
            self
        }
    }
}

extension View {
    func alert(isPresented: Binding<Bool>, title: Text, message: Text, action: @escaping () -> Void = {}) -> some View {
        alert(
            title,
            isPresented: isPresented
        ) {
            Button("リトライ") {
                isPresented.wrappedValue = false
                action()
            }
        } message: {
            message
        }
    }

    func alert(isPresented: Binding<Bool>, title: String, message: String, action: @escaping () -> Void = {}) -> some View {
        alert(isPresented: isPresented, title: Text(title), message: Text(message), action: action)
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

extension Binding where Value == Bool {
    init(value: Binding<(some Any)?>) {
        self.init(
            get: {
                value.wrappedValue != nil
            },
            set: {
                if !$0 {
                    value.wrappedValue = nil
                }
            }
        )
    }
}
