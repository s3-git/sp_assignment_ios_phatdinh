//
//  APIClient.swift
//  Weather App
//
//  Created by phat.dinh on 5/13/25.
//

import Foundation

class APIClient {
    func get(_ urlStr: String, params: Codable) async -> Data? {
        do {
            guard let paramsEncoded = try? JSONEncoder().encode(params),
                let json = try? JSONSerialization.jsonObject(with: paramsEncoded, options: []) as? [String: Any]
            else {
                fatalError("")
            }

            let paramsStr = json.keys.map { e in
                "\(e)=\(json[e]!)"
            }
            let fullUrl = [
                urlStr,
                paramsStr.joined(separator: "&"),
            ].joined(separator: "?")

            guard let url = URL(string: fullUrl) else {
                fatalError("\(fullUrl) is invalid!")
            }
            print(fullUrl)
            let urlRequest = URLRequest(url: url)
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            return data
        } catch {
            return nil
        }
    }
}
