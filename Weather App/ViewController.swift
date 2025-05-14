//
//  ViewController.swift
//  Weather App
//
//  Created by phat.dinh on 5/13/25.
//

import SwiftUI
import UIKit

struct City: Codable {
    let name: String
    let square: Double
}

class ViewController: UIViewController {
    private let CELL_CITY_ID = "CELL_CITY_ID"

    @IBOutlet weak var _mSearchBar: UISearchBar!
    @IBOutlet weak var _mTableView: UITableView!
    @IBOutlet weak var _mEmptyState: UIView!

    private var debounceTimer: Timer?

    private var dataSource: [SearchResult] = []
    private var recentlyViewed: [SearchResult] = StorageManager.shared.loadRecentlySearch() {
        didSet {
            let _ = StorageManager.shared.saveRecentlySearch(recentlyViewed)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        _mTableView.register(UINib(nibName: "CityItemCell", bundle: nil), forCellReuseIdentifier: CELL_CITY_ID)
        dataSource = recentlyViewed

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit, target: self, action: #selector(self.editTable))
    }

    @IBAction private func editTable() {
        self._mTableView.isEditing.toggle()
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceTimer?.invalidate()
        _mTableView.isEditing = false
        navigationItem.rightBarButtonItem?.isEnabled = searchText.isEmpty
        if searchText.isEmpty {
            self.dataSource = self.recentlyViewed
            self._mTableView.reloadData()
            return
        }
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            Task { @MainActor in
                let data = await NetworkManager.shared.searchCity(searchText)
                guard let result = data?.searchApi.result else {
                    return
                }

                self?.dataSource = result
                self?._mTableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        _mEmptyState.isHidden = !recentlyViewed.isEmpty || !dataSource.isEmpty

        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CITY_ID) as? CityItemCell else {
            return UITableViewCell()
        }
        cell.cityNameLabel.text = dataSource[indexPath.row].areaName.first?.value
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }

    func tableView(
        _ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            recentlyViewed = dataSource

            if recentlyViewed.isEmpty {
                _mEmptyState.isHidden = false
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = dataSource[indexPath.row]
        self.navigationController?.pushViewController(UIHostingController(rootView: CityScreen(city: city)), animated: true)

        if let lastIndex = self.recentlyViewed.firstIndex(where: { $0.areaName[0].value == city.areaName[0].value }) {
            self.recentlyViewed.move(fromOffsets: IndexSet(integer: lastIndex), toOffset: 0)
            self.dataSource = self.recentlyViewed
            self._mTableView.reloadData()
        } else {
            self.recentlyViewed.insert(city, at: 0)
            if self.recentlyViewed.count > 10 {
                self.recentlyViewed = Array(self.recentlyViewed.prefix(10))
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
