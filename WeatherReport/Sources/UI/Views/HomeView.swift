//
//  HomeView.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/14.
//

import SwiftUI

struct HomeView: View {
    @StateObject
    var viewModel: HomeViewModel = .init()

    var body: some View {
        VStack {
            Text("都市を選択してください")
                .font(.title2)
                .padding(.bottom, 16)
            CityList { city in
                viewModel.selectedCity(city)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigatorDestination($viewModel.navigation) { navigation in
            switch navigation {
            case let .weatherForecast(city):
                WeatherForecastView(viewModel: .init(city: city))
            }
        }
    }
}

private struct CityList: View {
    var selectCityAction: @MainActor (Forecast.City) -> Void

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(Forecast.City.allCases, id: \.self) { city in
                Button {
                    selectCityAction(city)
                } label: {
                    Text(title(city))
                        .font(.title3)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .animation(.spring(), value: city)
            }
        }
        .padding(.horizontal)
    }

    private func title(_ city: Forecast.City) -> LocalizedStringKey {
        switch city {
        case .tokyo:
            return "東京"
        case .osaka:
            return "大阪"
        case .hyogo:
            return "兵庫"
        case .oita:
            return "大分"
        case .hokkaido:
            return "北海道"
        case .current:
            return "現在地"
        }
    }

    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 2)
    }
}

#Preview {
    HomeView()
}
