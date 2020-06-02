//
//  SearchTableView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class SearchView: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var scrollContentView: UIView?
    
    @IBOutlet private weak var filterByNameView: UIView?
    @IBOutlet private weak var filterByIngredientView: UIView?
    @IBOutlet private weak var filterByRatingView: UIView?
    @IBOutlet private weak var filterByBookmarksAmountView: UIView?
    @IBOutlet private weak var filterByRatingsAmountView: UIView?
    @IBOutlet private weak var filterByMyBookmarks: UIView!
    @IBOutlet private weak var filterByMyRecipes: UIView!
    @IBOutlet private weak var searchButton: UIButton?
    
    @IBOutlet private weak var namesTextView: UITextView?
    @IBOutlet private weak var ingredientsTextView: UITextView?
    @IBOutlet private weak var ratingView: CosmosView?
    @IBOutlet private weak var bookmarksAmountTextField: UITextField!
    @IBOutlet private weak var ratingsAmountTextField: UITextField!
    @IBOutlet private weak var myBookmarksSwitch: UISwitch!
    @IBOutlet private weak var myRecipesSwitch: UISwitch!
    
    @IBAction private func searchClicked(_ sender: Any) {
        guard let namesTextView = namesTextView, let ingredientsTextView = ingredientsTextView,
            let ratingView = ratingView, let bookmarksAmountTextField = bookmarksAmountTextField,
            let ratingsAmountTextField = ratingsAmountTextField,
            let myBookmarksSwitch = myBookmarksSwitch, let myRecipesSwitch = myRecipesSwitch,
            let recipeTable = recipeTable
            else { return }        
        let filteredNames = namesTextView.text.isEmpty ? [] :
            namesTextView.text.components(separatedBy: ",").map { $0.lowercased() }
        
        let filteredIngredients = ingredientsTextView.text.isEmpty ? [] :
            ingredientsTextView.text.components(separatedBy: ",").map { $0.lowercased() }
        let filteredRating = ratingView.rating
        var bookmarksAmount = 0
        if let bookmarksAmountString = bookmarksAmountTextField.text, !bookmarksAmountString.isEmpty {
            bookmarksAmount = Int(bookmarksAmountString) ?? 0
        }
        var ratingsAmount = 0
        if let ratingsAmountString = ratingsAmountTextField.text, !ratingsAmountString.isEmpty {
            ratingsAmount = Int(ratingsAmountString) ?? 0
        }
        let myBookmarks = myBookmarksSwitch.isOn
        let myRecipes = myRecipesSwitch.isOn
        recipeTable.handleFilteredData(names: filteredNames, ingredients: filteredIngredients,
                                       minRating: filteredRating, minBookmarks: bookmarksAmount,
                                       minRatings: ratingsAmount, myBookmarks: myBookmarks, myRecipes: myRecipes)
        dismiss(animated: true, completion: nil)
    }
    
    private var recipeTable: RecipeTableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let scrollView = scrollView, let scrollContentView = scrollContentView,
            let filterByNameView = filterByNameView, let filterByIngredientView = filterByIngredientView,
            let filterByRatingView = filterByRatingView, let filterByBookmarksAmountView = filterByBookmarksAmountView,
            let filterByRatingsAmountView = filterByRatingsAmountView, let filterByMyBookmarks = filterByMyBookmarks,
            let filterByMyRecipes = filterByMyRecipes, let ratingView = ratingView, let searchButton = searchButton
            else { return }
        scrollView.addSubview(scrollContentView)
        NSLayoutConstraint.activate([
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0.0),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0.0),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0)
        ])
        
        ratingView.settings.fillMode = .precise
        ratingView.settings.filledImage = UIImage(named: SystemValues.imageStarFillName)?
            .withRenderingMode(.alwaysOriginal)
        ratingView.settings.emptyImage = UIImage(named: SystemValues.imageStarName)?
            .withRenderingMode(.alwaysOriginal)
        ratingView.settings.fillMode = .full
    
        filterByNameView.layer.cornerRadius = 16
        filterByNameView.clipsToBounds = true
        filterByIngredientView.layer.cornerRadius = 16
        filterByIngredientView.clipsToBounds = true
        filterByRatingView.layer.cornerRadius = 16
        filterByRatingView.clipsToBounds = true
        filterByBookmarksAmountView.layer.cornerRadius = 16
        filterByBookmarksAmountView.clipsToBounds = true
        filterByRatingsAmountView.layer.cornerRadius = 16
        filterByRatingsAmountView.clipsToBounds = true
        filterByMyBookmarks.layer.cornerRadius = 16
        filterByMyBookmarks.clipsToBounds = true
        filterByMyRecipes.layer.cornerRadius = 16
        filterByMyRecipes.clipsToBounds = true
        searchButton.layer.cornerRadius = 16
        searchButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
}

extension SearchView {
    func setRecipeTableView(recipeTable: RecipeTableView) {
        self.recipeTable = recipeTable
    }
}

extension SearchView {
    private func registerNotifications() {
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardFunc))
        guard let scrollContentView = scrollContentView else { return }
        scrollContentView.addGestureRecognizer(hideKeyboard)
    }
    
    @objc private func hideKeyboardFunc() {
        guard let scrollContentView = scrollContentView else { return }
        scrollContentView.endEditing(true)
    }
}
