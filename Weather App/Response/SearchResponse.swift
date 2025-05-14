//
//  SearchResponse.swift
//  Weather App
//
//  Created by phat.dinh on 5/13/25.
//

struct SearchResponse: Codable {
    let searchApi: SearchAPIResponse

    enum CodingKeys: String, CodingKey {
        case searchApi = "search_api"
    }
}

struct SearchAPIResponse: Codable {
    let result: [SearchResult]
}

struct StringValue: Codable {
    let value: String
}

struct SearchResult: Codable {
    let areaName: [StringValue]
    let country: [StringValue]
    let latitude: String
    let longitude: String
    let population: String
    let weatherUrl: [StringValue]
    let region: [StringValue]
}
