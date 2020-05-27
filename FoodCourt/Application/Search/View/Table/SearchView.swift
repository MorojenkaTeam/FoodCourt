//
//  SearchTableView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class SearchView: UIViewController {
    @IBOutlet private weak var filterByNameView: UIView?
    @IBOutlet private weak var filterByIngredientView: UIView?
    @IBOutlet private weak var filterByRatingView: UIView?
    @IBOutlet private weak var filterByFavoriteView: UIView?
    
    @IBOutlet private weak var namesTextView: UITextView?
    @IBOutlet private weak var ingredientsTextView: UITextView?
    @IBOutlet private weak var ratingSlider: UISlider?
    @IBOutlet private weak var favoritesSwitch: UISwitch?
    @IBOutlet private weak var searchButton: UIButton?
    
    @IBAction private func searchClicked(_ sender: Any) {
        /*print("4eburek")
        if favoritesSwitch == nil {
            print(1)
        }
        
        if namesTextView == nil {
            print(2)
        }
        
        if ingredientsTextView == nil {
            print(3)
        }
        
        if ratingSlider == nil {
            print(4)
        }*/
        guard let namesTextView = namesTextView, let ingredientsTextView = ingredientsTextView,
            let ratingSlider = ratingSlider, let favoritesSwitch = favoritesSwitch, let recipeTable = recipeTable
            else { return }        
        let filteredNames = namesTextView.text.isEmpty ? [] :
            namesTextView.text.components(separatedBy: ",").map { $0.lowercased() }
        
        let filteredIngredients = ingredientsTextView.text.isEmpty ? [] :
            ingredientsTextView.text.components(separatedBy: ",").map { $0.lowercased() }
        let filteredRating = ratingSlider.value
        let filteredFavorite = favoritesSwitch.isOn
        recipeTable.handleFilteredData(names: filteredNames, ingredients: filteredIngredients,
                                        minRating: filteredRating, onlyFavorites: filteredFavorite)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        guard let ratingSlider = ratingSlider else { return }
        ratingSlider.value = roundf(ratingSlider.value)
    }
    
    private var recipeTable: RecipeTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let filterByNameView = filterByNameView, let filterByIngredientView = filterByIngredientView,
            let filterByRatingView = filterByRatingView, let filterByFavoriteView = filterByFavoriteView,
            let searchButton = searchButton
            else { return }
        filterByNameView.layer.cornerRadius = 16
        filterByNameView.clipsToBounds = true
        filterByIngredientView.layer.cornerRadius = 16
        filterByIngredientView.clipsToBounds = true
        filterByRatingView.layer.cornerRadius = 16
        filterByRatingView.clipsToBounds = true
        filterByFavoriteView.layer.cornerRadius = 16
        filterByFavoriteView.clipsToBounds = true
        searchButton.layer.cornerRadius = 16
        searchButton.clipsToBounds = true

    }
}

extension SearchView {
    func setRecipeTableView(recipeTable: RecipeTableView) {
        self.recipeTable = recipeTable
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

