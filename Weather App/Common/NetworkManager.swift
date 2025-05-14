//
//  NetworkManager.swift
//  Weather App
//
//  Created by phat.dinh on 5/13/25.
//

import Foundation

class NetworkManager {
    private let weatherAPIKey = "fcac5fe6ea0347baa5b44514251305"
    private let apiClient = APIClient()
    
    private let expireTimeInterval: TimeInterval = 60
    private var cachedData: [String: (Date,WeatherResponse)] = [:]
    
    static let shared: NetworkManager = .init()
    private init() {}
    
    func searchCity(_ keyword: String) async -> SearchResponse? {
        guard let data = await apiClient.get("https://api.worldweatheronline.com/premium/v1/search.ashx", params: [
            "key": weatherAPIKey,
            "format": "json",
            "query": keyword])
        else {
            return nil
        }
        
        
        do {
            let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
            return decoded
        } catch {
            print("error: \(error.localizedDescription)")
            print("error: \(data.debugDescription)")
        }
        
        return nil
        
    }
    
    func getWeather(at lat: Double, lon: Double) async -> WeatherResponse? {
        var response: WeatherResponse?
        if let cacheData = cachedData["\(lat),\(lon)"], Date().timeIntervalSince(cacheData.0) < expireTimeInterval {
            print("Using cached data")
            response = cacheData.1
        }
        
        guard let data = await apiClient.get("https://api.worldweatheronline.com/premium/v1/weather.ashx", params: [
            "key": weatherAPIKey,
            "format": "json",
            "num_of_days": "1",
            "q": "\(lat),\(lon)"])
        else {
            return nil
        }
        
        
        do {
            let decoded = try JSONDecoder().decode(WeatherResponse.self, from: data)
            cachedData["\(lat),\(lon)"] = (Date(), decoded)
            response = decoded
        } catch {
            print("error: \(error.localizedDescription)")
            print("error: \(data.debugDescription)")
        }
        
        do {
            let encoded = try JSONEncoder().encode(response)
            print(encoded.prettyPrintedJSONString ?? "")
        } catch {
            
        }
        return response
        
    }
}
