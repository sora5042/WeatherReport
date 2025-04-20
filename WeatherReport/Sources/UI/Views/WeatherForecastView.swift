//
//  WeatherForecastView.swift
//  WeatherReport
//
//  Created by Sora Oya on 2025/04/15.
//

import SwiftUI

struct WeatherForecastView: View {
    @StateObject
    var viewModel: WeatherForecastViewModel

    @Environment(\.dismiss)
    var dismiss

    var body: some View {
        VStack {
            if let row = viewModel.row {
                ForecastList(
                    row: row
                )
            }
        }
        .navigationTitle(viewModel.row?.cityName ?? "")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .alert($viewModel.error) {
            Task {
                await viewModel.fetchForecast()
            }
        }
        .alert(
            "リトライの上限に達しました。",
            isPresented: $viewModel.alert.retryLimit
        ) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("しばらく時間をおいてから再度お試しください")
        }
        .task {
            await viewModel.fetchForecast()
        }
        .loading(isPresented: viewModel.isLoading)
    }
}

private struct ForecastList: View {
    var row: WeatherForecastViewModel.Row

    var body: some View {
        List {
            ForEach(row.weather.groupedByDay(), id: \.date) { section in
                Section(header:
                    HStack {
                        Spacer()
                        Text(section.date)
                            .font(.headline)
                            .foregroundStyle(.black)
                        Spacer()
                    }
                ) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(section.weathers, id: \.self) { weather in
                                Row(
                                    temperature: weather.temperature,
                                    maxTemperature: weather.maxTemperature,
                                    minTemperature: weather.minTemperature,
                                    pop: weather.pop,
                                    description: weather.description,
                                    iconURL: weather.iconURL,
                                    date: weather.date.components(separatedBy: " ").last ?? weather.date
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct Row: View {
    var temperature: Int
    var maxTemperature: Int
    var minTemperature: Int
    var pop: Int
    var description: String
    var iconURL: URL?
    var date: String

    var body: some View {
        VStack(spacing: 10) {
            Text(date)
            HStack(spacing: 20) {
                Spacer()
                VStack {
                    AsyncImage(url: iconURL) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(.circle)
                        case .failure:
                            Image(systemName: "sun.max.trianglebadge.exclamationmark")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(.gray)
                        default:
                            ProgressView()
                        }
                    }
                    Text(description)
                }
                VStack(spacing: 10) {
                    Text("最高: \(maxTemperature)℃")
                    Text("最低: \(minTemperature)℃")
                    Text("降水確率: \(pop)%")
                }
                Spacer()
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(8)
    }
}

#Preview {
    WeatherForecastView(viewModel: .init(city: .osaka))
}
