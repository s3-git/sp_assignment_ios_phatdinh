//
//  CityScreen.swift
//  Weather App
//
//  Created by phat.dinh on 5/13/25.
//

import SwiftUI

struct CityScreen: View {

    let city: SearchResult

    @State private var weather: WeatherData?

    var body: some View {
        VStack {
            if let weatherIcon = self.weather?.currentCondition.first?.weatherIconURL.first?.value {
                AsyncImage(url: URL(string: weatherIcon))
                    .frame(width: 50, height: 50)
                    .padding()
            }
            if let time = self.weather?.currentCondition.first?.observationTime {
                Text(time)
            }
            List {
                HStack {
                    Text("Humidity")
                    Spacer()
                    Text("\(self.weather?.currentCondition.first?.humidity ?? "-")%")
                }
                HStack {
                    Text("Temperature")
                    Spacer()
                    Text(
                        "\(self.weather?.currentCondition.first?.tempC ?? "-")°C / \(self.weather?.currentCondition.first?.tempF ?? "-")°F"
                    )
                }
                HStack {
                    Text("Windspeed")
                    Spacer()
                    Text(
                        "\(self.weather?.currentCondition.first?.windspeedKmph ?? "-") Kmph / \(self.weather?.currentCondition.first?.windspeedMiles ?? "-") miles"
                    )
                }
            }
        }
        .task {
            guard let lat = Double(city.latitude), let lon = Double(city.longitude) else {
                return
            }
            weather = (await NetworkManager.shared.getWeather(at: lat, lon: lon))?.data

        }
        .navigationTitle(self.city.areaName.first?.value ?? "")
    }
}
