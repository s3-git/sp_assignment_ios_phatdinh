//
//  Weather_AppTests.swift
//  Weather AppTests
//
//  Created by phat.dinh on 5/13/25.
//
import Foundation
import Testing

@testable import Weather_App

struct Weather_AppTests {
    // MARK: - NetworkManager Tests
    @Test func testNetworkManagerSearchCity() async throws {
        let networkManager = NetworkManager.shared
        let result = await networkManager.searchCity("London")
        #expect(result != nil)
        #expect(result?.searchApi.result.isEmpty == false)
    }

    @Test func testNetworkManagerGetWeather() async throws {
        let networkManager = NetworkManager.shared
        let result = await networkManager.getWeather(at: 51.5074, lon: -0.1278)  // London coordinates
        #expect(result != nil)
        #expect(result?.data.currentCondition.isEmpty == false)
    }

    @Test func testNetworkManagerCaching() async throws {
        let networkManager = NetworkManager.shared
        let lat = 51.5074
        let lon = -0.1278

        // First call
        let result1 = await networkManager.getWeather(at: lat, lon: lon)
        #expect(result1 != nil)

        // Second call should use cache
        let result2 = await networkManager.getWeather(at: lat, lon: lon)
        #expect(result2 != nil)
        #expect(result1?.data.currentCondition.first?.tempC == result2?.data.currentCondition.first?.tempC)
    }

    // MARK: - StorageManager Tests
    @Test func testStorageManagerSaveAndLoad() throws {
        let storageManager = StorageManager.shared

        // Create test data
        let testResult = SearchResult(
            areaName: [StringValue(value: "Test City")],
            country: [StringValue(value: "Test Country")],
            latitude: "0",
            longitude: "0",
            population: "0",
            weatherUrl: [StringValue(value: "http://test.com")],
            region: [StringValue(value: "Test Region")]
        )

        // Test saving
        let saveResult = storageManager.saveRecentlySearch([testResult])
        #expect(saveResult == true)

        // Test loading
        let loadedResults = storageManager.loadRecentlySearch()
        #expect(loadedResults.count == 1)
        #expect(loadedResults.first?.areaName.first?.value == "Test City")
    }

    // MARK: - Data Model Tests
    @Test func testWeatherResponseDecoding() throws {
        let jsonString = """
            {
                "data": {
                    "request": [{"type": "City", "query": "London"}],
                    "current_condition": [{
                        "observation_time": "12:00 PM",
                        "temp_C": "20",
                        "temp_F": "68",
                        "weatherCode": "113",
                        "weatherIconUrl": [{"value": "http://test.com/icon.png"}],
                        "weatherDesc": [{"value": "Sunny"}],
                        "windspeedMiles": "10",
                        "windspeedKmph": "16",
                        "winddirDegree": "180",
                        "winddir16Point": "S",
                        "precipMM": "0",
                        "precipInches": "0",
                        "humidity": "50",
                        "visibility": "10",
                        "visibilityMiles": "6",
                        "pressure": "1012",
                        "pressureInches": "30",
                        "cloudcover": "0",
                        "FeelsLikeC": "20",
                        "FeelsLikeF": "68",
                        "uvIndex": "6"
                    }],
                    "weather": [],
                    "ClimateAverages": []
                }
            }
            """

        let jsonData = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(WeatherResponse.self, from: jsonData)

        #expect(response.data.request.first?.query == "London")
        #expect(response.data.currentCondition.first?.tempC == "20")
        #expect(response.data.currentCondition.first?.tempF == "68")
        #expect(response.data.currentCondition.first?.weatherDesc.first?.value == "Sunny")
    }

    @Test func testSearchResponseDecoding() throws {
        let jsonString = """
            {
                "search_api": {
                    "result": [{
                        "areaName": [{"value": "London"}],
                        "country": [{"value": "United Kingdom"}],
                        "latitude": "51.5074",
                        "longitude": "-0.1278",
                        "population": "8908081",
                        "weatherUrl": [{"value": "http://test.com"}],
                        "region": [{"value": "City of London"}]
                    }]
                }
            }
            """

        let jsonData = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(SearchResponse.self, from: jsonData)

        #expect(response.searchApi.result.first?.areaName.first?.value == "London")
        #expect(response.searchApi.result.first?.country.first?.value == "United Kingdom")
        #expect(response.searchApi.result.first?.latitude == "51.5074")
        #expect(response.searchApi.result.first?.longitude == "-0.1278")
    }

    // MARK: - APIClient Tests
    @Test func testAPIClientGet() async throws {
        let apiClient = APIClient()
        let params = ["key": "test", "format": "json"]
        let data = await apiClient.get("https://api.worldweatheronline.com/premium/v1/search.ashx", params: params)
        #expect(data != nil)
    }
}
