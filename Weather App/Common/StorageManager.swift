//
//  StorageManager.swift
//  Weather App
//
//  Created by phat.dinh on 5/14/25.
//

import Foundation

class StorageManager {
    static let shared: StorageManager = .init()
    private init() {}

    private let kRECENTLY_SEARCH_RESULT = "kRECENTLY_SEARCH_RESULT"

    func saveRecentlySearch(_ results: [SearchResult]) -> Bool {
        do {
            UserDefaults.standard.set(try JSONEncoder().encode(results), forKey: kRECENTLY_SEARCH_RESULT)
            print("Saved")
            return UserDefaults.standard.synchronize()
        } catch {
            print("Save failed: \(error.localizedDescription)")
            return false
        }
    }

    func loadRecentlySearch() -> [SearchResult] {
        do {
            guard let data = UserDefaults.standard.data(forKey: kRECENTLY_SEARCH_RESULT) else {
                print("There is no data in cache")
                return []
            }
            let results = try JSONDecoder().decode([SearchResult].self, from: data)
            print("Loaded \(results.count) items")
            return results
        } catch {
            print("Load failed: \(error.localizedDescription)")
            return []
        }

    }
}
