//
//  SearchTableView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class SearchTableView: UIViewController {
    //@IBOutlet private weak var searchTable: UITableView?
    
    /*private let filters : [String] = [
        TableCellConfig.filterByNameCellIdentifier,
        TableCellConfig.filterByIngredientCellIdentifier,
        TableCellConfig.filterByRatingCellIdentifier
    ]*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        /*guard let searchTable = searchTable else { return }
        searchTable.dataSource = self
        searchTable.delegate = self
        for identifier in filters {
            searchTable.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        }*/
    }
}

/*extension SearchTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableCellConfig.numberOfRowsInSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableCellConfig.spaceBetweenCells
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: filters[indexPath.section], for: indexPath)
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0;
        switch indexPath.row{
        case 0:
            height = 405
        case 1, 2:
            height = 67
        case 3:
            height = 120
        default:
            height = 67
        }
        return CGFloat(height)
    }*/
}*/

