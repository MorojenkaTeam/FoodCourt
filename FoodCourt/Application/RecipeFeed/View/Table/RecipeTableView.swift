//
//  RecipeTableView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecipeTableView: UIViewController {
    @IBOutlet private weak var recipeTableView: UITableView?
    @IBOutlet private weak var recipeSearch: UIImageView?
    @IBOutlet private weak var errorLabel: UILabel?
    
    private var allRecipes = [Recipe]()
    private var filteredRecipes = [Recipe]()
    private var recipesForShow = [Recipe]()
    private var recipeImages = [String: Data]()
    private var rowStates = [Bool]()
    private var favorites = Set<String>()
    
    private var viewModel: RecipeTableViewModel?
    private var currentUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let errorLabel = errorLabel, let recipeTableView = recipeTableView, let recipeSearch = recipeSearch
            else { return }
        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        recipeTableView.register(UINib(nibName: TableCellConfig.recipeCellIdentifier, bundle: nil),
                                 forCellReuseIdentifier: TableCellConfig.recipeCellIdentifier)
        
        recipeSearch.image = UIImage(systemName: "magnifyingglass")
        let clicked = UITapGestureRecognizer(target: self, action: #selector(searchClicked))
        recipeSearch.isUserInteractionEnabled = true
        recipeSearch.addGestureRecognizer(clicked)
        errorLabel.alpha = 0
        
        if InternetConnectionManager.isConnectedToNetwork() {
            viewModel = RecipeTableViewModel()
            downloadRecipeData()
        } else {
            
        }
    }
    
    private func uploadToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Recipe", in: context) else {
            return
        }
        for recipe in allRecipes {
            let recipeData = NSManagedObject(entity: entity, insertInto: context)
            recipeData.setValue(recipe.getId(), forKey: Fields.recipeId)
            recipeData.setValue(recipe.getAuthorId(), forKey: Fields.recipeAuthotId)
            recipeData.setValue(recipe.getName(), forKey: Fields.recipeName)
            recipeData.setValue(recipe.getDescription(), forKey: "recipeDescription")
            recipeData.setValue(recipe.getRating(), forKey: Fields.recipeRationg)
        }
        
    }
    
    private func downloadFromCoreData() {
        
    }
    
    @objc func searchClicked() {
        let searchView = SearchView()
        searchView.setRecipeTableView(recipeTable: self)
        present(searchView, animated: true, completion: nil)
    }
}

extension RecipeTableView {
    private func downloadRecipeData() {
        guard let viewModel = viewModel else { return }
        viewModel.downloadRecipes(completion: { [weak self] (recipes, error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleFirestoreError(error: error)
                    self.showToast(message: receivedError)
                } else {
                    guard let recipes = recipes else { return }
                    self.recipesForShow = recipes
                    self.allRecipes = recipes
                    guard let recipeTableView = self.recipeTableView else { return }
                    self.rowStates = Array(repeating: false, count: recipes.count)
                    recipeTableView.reloadData()
                    self.downloadRecipeImages()
                    self.setFavorites()
                }
        })
    }
    
    private func setFavorites() {
        guard let currentUsername = currentUsername, let recipeTableView = recipeTableView else {
            return
        }
        for (index, recipe) in allRecipes.enumerated() {
            for userId in recipe.getWhoseFavorites() {
                if userId == currentUsername {
                    let indexPath = IndexPath(row: 0, section: index)
                    guard let cell = recipeTableView.dataSource?.tableView(recipeTableView,
                                                                     cellForRowAt: indexPath) as? RecipeTableViewCell
                        else { return }
                    cell.setAsFavorite()
                    favorites.insert(recipe.getId())
                }
            }
        }
    }
    
    /*private func downloadFavorites() {
        guard let viewModel = viewModel else { return }
        viewModel.downloadFavorites(completion: { [weak self] (favorites, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleFirestoreError(error: error)
                    self.showToast(message: receivedError)
                }
                
                guard let favorites = favorites else {
                    print("FAVORITES RECIPES NIL (VIEW: 89)")
                    return
                }
                
                self.favorites = Set(favorites.map { $0 })
                
                guard let recipeTableView = self.recipeTableView else {
                    return
                }
                
                for (index, recipe) in self.recipesForShow.enumerated() {
                    if self.favorites.contains(recipe.getId()) {
                        let indexPath = IndexPath(row: 0, section: index)
                        guard let cell = recipeTableView.cellForRow(at: indexPath) as? RecipeTableViewCell
                            else { return }
                        cell.setIsFavorite(true)
                        
                        cell.setAsFavorite()
                        
                    }
                    self.downloadRecipeImages()
                }
            }
        })
    }*/
    
    private func downloadRecipeImages() {
        guard let viewModel = viewModel else { return }
        for (index, recipe) in recipesForShow.enumerated() {
            let recipeId = recipe.getId()
            viewModel.downloadRecipeImage(id: recipeId, completion: { [weak self] (imageData, error) in
                //DispatchQueue.main.async {
                    guard let self = self else { return }
                    if let error = error {
                        let receivedError = self.handleStorageError(error: error)
                        self.showToast(message: receivedError)
                    }
                    
                    guard let imageData = imageData else {
                        return
                    }
                    
                    let indexPath = IndexPath(row: 0, section: index)
                    guard let recipeTableView = self.recipeTableView,
                        let image = UIImage(data: imageData),
                        let cell = recipeTableView.dataSource?.tableView(recipeTableView,
                                                                     cellForRowAt: indexPath) as? RecipeTableViewCell
                    //guard let cell = recipeTableView.cellForRow(at: indexPath) as? RecipeTableViewCell
                        else { return }
                    cell.setImage(image: image)
                    self.recipesForShow[index].setImage(image: image)
                    self.allRecipes[index].setImage(image: image)
                    self.recipeImages[recipeId] = imageData
                //}
            })
        }
    }
    
    func uploadFavoritesChanges(recipeId: String, changeFlag: Bool) {
        guard let viewModel = viewModel else { return }
        viewModel.uploadFavoritesChanges(id: recipeId, changeFlag: changeFlag, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            } else {
                if changeFlag {
                    self.favorites.insert(recipeId)
                    for recipe in self.allRecipes {
                        if recipe.getId() == recipeId {
                            recipe.insertFan(id: recipeId)
                            break
                        }
                    }
                } else {
                    self.favorites.remove(recipeId)
                    for recipe in self.allRecipes {
                        if recipe.getId() == recipeId {
                            recipe.insertFan(id: recipeId)
                            break
                        }
                    }
                }
            }
        })
    }
}

extension RecipeTableView {
    private func handleFirestoreError(error: ErrorViewModel) -> String {
        switch error {
        case .cancelledFirestoreError:
            return ErrorView.cancelledFirestoreError
        case .invalidArgumentFirestoreError:
            return ErrorView.invalidArgumentFirestoreError
        case .deadlineExceeded:
            return ErrorView.deadlineExceeded
        case .notFound:
            return ErrorView.notFound
        case .alreadyExists:
            return ErrorView.alreadyExists
        case .permissionDenied:
            return ErrorView.permissionDenied
        case .resourceExhausted:
            return ErrorView.resourceExhausted
        case .failedPrecondition:
            return ErrorView.failedPrecondition
        case .aborted:
            return ErrorView.aborted
        case .outOfRange:
            return ErrorView.outOfRange
        case .unimplemented:
            return ErrorView.unimplemented
        case .`internal`:
            return ErrorView.`internal`
        case .unavailable:
            return ErrorView.unavailable
        case .dataLoss:
            return ErrorView.dataLoss
        case .unauthenticatedFirestoreError:
            return ErrorView.unauthenticatedFirestoreError
        default:
            return ErrorView.unknownFirestoreError
        }
    }
    
    private func handleStorageError(error: ErrorViewModel) -> String {
        switch error {
        case .objectNotFound:
            return ErrorView.objectNotFound
        case .bucketNotFound:
            return ErrorView.bucketNotFound
        case .projectNotFound:
            return ErrorView.projectNotFound
        case .quotaExceeded:
            return ErrorView.quotaExceeded
        case .unauthenticatedStorageError:
            return ErrorView.unauthenticatedStorageError
        case .unauthorized:
            return ErrorView.unauthorized
        case .retryLimitExceeded:
            return ErrorView.retryLimitExceeded
        case .nonMatchingChecksum:
            return ErrorView.nonMatchingChecksum
        case .downloadSizeExceeded:
            return ErrorView.downloadSizeExceeded
        case .cancelledStorageError:
            return ErrorView.cancelledStorageError
        case .invalidArgumentStorageError:
            return ErrorView.invalidArgumentStorageError
        default:
            return ErrorView.unknownStorageError
        }
    }
    
    private func showToast(message: String) {
        guard let errorLabel = errorLabel else { return }
        errorLabel.textAlignment = .center
        errorLabel.text = message
        errorLabel.alpha = 1.0
        errorLabel.layer.cornerRadius = 16;
        errorLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 4.0, options: .curveEaseOut, animations: {
            errorLabel.alpha = 0.0
        })
    }
    
    func handleFilteredData(names: [String], ingredients: [String], minRating: Float, onlyFavorites: Bool) {
        filteredRecipes = onlyFavorites ? allRecipes.filter { favorites.contains($0.getId()) } : allRecipes
        
        if minRating != 0 {
            filteredRecipes = filteredRecipes.filter { $0.getRating() >= Double(minRating)}
        }
        
        if !names.isEmpty {
            let set = Set(names)
            filteredRecipes = filteredRecipes.filter { set.contains($0.getName()) }
        }
        
        if !ingredients.isEmpty {
            let set = Set(ingredients)
            filteredRecipes = filteredRecipes.filter { (recipe) in
                let recipeIngredients = recipe.getIngredients().map { $0.getName() }
                for ingredient in recipeIngredients {
                    if set.contains(ingredient) {
                        return true
                    }
                }
                return false
            }
        }
        
        recipesForShow = filteredRecipes
        guard let recipeTableView = recipeTableView else { return }
            recipeTableView.reloadData()
    }
    
    func setUsername(username: String) {
        currentUsername = username
    }
}

extension RecipeTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableCellConfig.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCellConfig.recipeCellIdentifier,
                                                       for: indexPath) as? RecipeTableViewCell
            else {
                let cell = RecipeTableViewCell()
                return cell
        }
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let recipe = recipesForShow[indexPath.section]
        if let imageData = recipeImages[recipe.getId()] {
            cell.configure(with: recipe, image: UIImage(data: imageData), tableController: self)
        } else {
            cell.configure(with: recipe, image: nil, tableController: self)
        }
        
        if recipeImages[recipe.getId()] == nil {
            print("is nill")
        }
        
        /*if let image = recipe.getImage() {
         cell.setImage(image: image)
         }*/
        favorites.contains(recipe.getId()) ? cell.setAsFavorite() : cell.setAsNotFavorite()
        cell.setIsExpanded(rowStates[indexPath.section])
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipesForShow.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableCellConfig.spaceBetweenCells
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell
            else { return }
        rowStates[indexPath.section].toggle()
        tableView.performBatchUpdates({
            cell.setIsExpanded(rowStates[indexPath.section])
        }, completion: nil)
    }
}
