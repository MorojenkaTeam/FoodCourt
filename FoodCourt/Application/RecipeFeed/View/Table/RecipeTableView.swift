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
    
    private var viewModel: RecipeTableViewModel?
    private var currentUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //deleteAllCoreData(entity: SystemNames.RecipeCoreDataClass) //func for develop
        configure()
    }
    
    private func configure() {
        guard let errorLabel = errorLabel, let recipeTableView = recipeTableView, let recipeSearch = recipeSearch
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        recipeTableView.register(UINib(nibName: SystemValues.recipeCellIdentifier, bundle: nil),
                                 forCellReuseIdentifier: SystemValues.recipeCellIdentifier)
        
        recipeSearch.image = UIImage(named: SystemValues.imageMagnifierName)?.withRenderingMode(.alwaysOriginal)
        let clicked = UITapGestureRecognizer(target: self, action: #selector(searchClicked))
        recipeSearch.isUserInteractionEnabled = true
        recipeSearch.addGestureRecognizer(clicked)
        errorLabel.alpha = 0
        
        viewModel = RecipeTableViewModel()
        if InternetConnectionManager.isConnectedToNetwork() {
            downloadRecipeData()
        } else {
            downloadFromCoreData()
        }
    }
    
    @objc func searchClicked() {
        let searchView = SearchView()
        searchView.setRecipeTableView(recipeTable: self)
        present(searchView, animated: true, completion: nil)
    }
}

extension RecipeTableView {
    private func downloadRecipeData() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.downloadRecipes(completion: { [weak self] (recipes, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            }
            guard let recipes = recipes else {
                self.showToast(message: ErrorView.nilData)
                return
            }
            self.setRecipes(recipes: recipes)
            self.downloadRecipeImages()
            self.observeRealtimeRecipeUpdates()
        })
    }
    
    private func setRecipes(recipes: [Recipe]) {
        self.recipesForShow = recipes
        self.allRecipes = recipes
        guard let recipeTableView = self.recipeTableView else { return }
        recipeTableView.reloadData()
    }
    
    private func downloadRecipeImage(recipe: Recipe) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.downloadRecipeImage(id: recipe.id, completion: { [weak self] (imageData, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleStorageError(error: error)
                self.showToast(message: receivedError)
            }
            guard let imageData = imageData, let image = UIImage(data: imageData) else {
                self.showToast(message: ErrorView.nilData)
                return
            }
            guard let recipeTableView = self.recipeTableView else {
                self.showToast(message: ErrorView.systemError)
                return
            }
            self.recipeImages[recipe.id] = imageData
            recipe.setImage(image: image)
            for (index, recipeItem) in self.recipesForShow.enumerated() {
                if recipe == recipeItem {
                    recipeTableView.beginUpdates()
                    recipeTableView.reloadSections([index], with: .none)
                    
                    recipeTableView.endUpdates()
                    break
                }
            }
            self.createObjectInCoreData(recipe: recipe)
        })
    }
    
    private func downloadRecipeImages() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        for (index, recipe) in recipesForShow.enumerated() {
            let recipeId = recipe.id
            viewModel.downloadRecipeImage(id: recipeId, completion: { [weak self] (imageData, error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleStorageError(error: error)
                    self.showToast(message: receivedError)
                }
                guard let imageData = imageData else {
                    self.showToast(message: ErrorView.nilData)
                    return
                }
                let indexPath = IndexPath(row: 0, section: index)
                guard let recipeTableView = self.recipeTableView,
                    let image = UIImage(data: imageData),
                    let cell = recipeTableView.dataSource?.tableView(recipeTableView,
                                                                     cellForRowAt: indexPath) as? RecipeTableViewCell
                    else {
                        self.showToast(message: ErrorView.systemError)
                        return
                }
                cell.setImage(image: image)
                self.allRecipes[index].setImage(image: image)
                self.recipeImages[recipeId] = imageData
                recipeTableView.beginUpdates()
                recipeTableView.reloadSections([index], with: .none)
                recipeTableView.endUpdates()
                self.createObjectInCoreData(recipe: recipe)
            })
        }
    }
    
    func uploadFavoritesChanges(recipeId: String, changeFlag: Bool, cell: RecipeTableViewCell) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.uploadFavoritesChanges(id: recipeId, changeFlag: changeFlag, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                cell.toggleIsFavorite()
                self.showToast(message: receivedError)
            }
        })
    }
    
    func uploadRatingChanges(id: String, receivedRating: Double, cell: RecipeTableViewCell) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.uploadRatingChanges(id: id, receivedRating: receivedRating, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                cell.toggleIsRated()
                self.showToast(message: receivedError)
            }
        })
    }
    
    func observeRealtimeRecipeUpdates() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.observeRealtimeRecipeUpdates(completion: { [weak self] (recipe, changeType, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            }
            guard let recipe = recipe else {
                self.showToast(message: ErrorView.nilData)
                return
            }
            switch changeType {
            case .added:
                print("recipe <\(recipe.name)> was added")
                self.addCellToTheTop(recipe: recipe)
            case .modified:
                print("recipe <\(recipe.name)> was modified")
                self.modifyCell(recipe: recipe)
                self.modifyObjectInCoreData(recipe: recipe)
            case .removed:
                print("recipe <\(recipe.name)> was removed")
                self.removeCell(recipe: recipe)
                self.deleteObjectFromCoreData(recipeId: recipe.id)
            default:
                print("wrong snapshot type")
                break
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
    
    private func handleCoreDataError(error: ErrorViewModel) -> String {
        switch error {
        case .validationError:
            return ErrorView.validationError
        case .coreDataAbort:
            return ErrorView.coreDataAbort
        case .missingMandatoryPropertyError:
            return ErrorView.missingMandatoryPropertyError
        case .relationshipLacksMinimumCountError:
            return ErrorView.relationshipLacksMinimumCountError
        case .relationshipExceedsMaximumCountError:
            return ErrorView.relationshipExceedsMaximumCountError
        case .relationshipDeniedDeleteError:
            return ErrorView.relationshipDeniedDeleteError
        case .numberTooLargeError:
            return ErrorView.numberTooLargeError
        case .numberTooSmallError:
            return ErrorView.numberTooSmallError
        case .dateTooLateError:
            return ErrorView.dateTooLateError
        case .dateTooSoonError:
            return ErrorView.dateTooSoonError
        case .invalidDateError:
            return ErrorView.invalidDateError
        case .stringTooLongError:
            return ErrorView.stringTooLongError
        case .stringTooShortError:
            return ErrorView.stringTooShortError
        case .stringPatternMatchingError:
            return ErrorView.stringPatternMatchingError
        default:
            return ErrorView.unknownCoreDataError
        }
    }
    
    func showToast(message: String) {
        guard let errorLabel = errorLabel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        errorLabel.textAlignment = .center
        errorLabel.text = message
        errorLabel.alpha = 1.0
        errorLabel.layer.cornerRadius = 16;
        errorLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 4.0, options: .curveEaseOut, animations: {
            errorLabel.alpha = 0.0
        })
    }
    
    func handleFilteredData(names: [String], ingredients: [String], minRating: Double, minBookmarks: Int,
                            minRatings: Int, myBookmarks: Bool, myRecipes: Bool) {
        filteredRecipes = myRecipes ? filteredRecipes.filter { $0.authorId == currentUsername } : allRecipes
        
        if myBookmarks {
            filteredRecipes = filteredRecipes.filter {
                for username in $0.whoseFavorites {
                    if username == currentUsername {
                        return true
                    }
                }
                return false
            }
        }
        
        if minRating != 0 {
            filteredRecipes = filteredRecipes.filter { $0.rating >= minRating }
        }
        
        if minBookmarks > 0 {
            filteredRecipes = filteredRecipes.filter { $0.whoseFavorites.count >= minBookmarks }
        }
        
        if minRatings > 0 {
            filteredRecipes = filteredRecipes.filter { $0.whoRated.count >= minRatings }
        }
        
        if !names.isEmpty {
            let set = Set(names)
            filteredRecipes = filteredRecipes.filter { set.contains($0.name.lowercased()) }
        }
        
        if !ingredients.isEmpty {
            let set = Set(ingredients)
            filteredRecipes = filteredRecipes.filter { (recipe) in
                let recipeIngredients = recipe.ingredients.map { $0.name.lowercased() }
                for ingredient in recipeIngredients {
                    if set.contains(ingredient) {
                        return true
                    }
                }
                return false
            }
        }
        
        recipesForShow = filteredRecipes
        guard let recipeTableView = recipeTableView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        recipeTableView.reloadData()
    }
    
    func setUsername(username: String) {
        currentUsername = username
    }
    
    private func addCellToTheTop(recipe: Recipe) {
        if !allRecipes.contains(recipe) {
            guard let recipeTableView = self.recipeTableView else {
                self.showToast(message: ErrorView.systemError)
                return
            }
            allRecipes.insert(recipe, at: 0)
            if allRecipes.count - 1 == recipesForShow.count {
                recipesForShow.insert(recipe, at: 0)
                recipeTableView.beginUpdates()
                recipeTableView.insertSections([0], with: .automatic)
                recipeTableView.endUpdates()
            }
            downloadRecipeImage(recipe: recipe)
        }
    }
    
    private func modifyCell(recipe: Recipe) {
        guard let recipeTableView = self.recipeTableView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        for (index, recipeItem) in allRecipes.enumerated() {
            if recipe == recipeItem {
                recipeItem.setRating(rating: recipe.rating)
                recipeItem.setWhoRated(whoRated: recipe.whoRated)
                recipeItem.setWhoseFavorites(whoseFavorites: recipe.whoseFavorites)
                if allRecipes.count == recipesForShow.count {
                    /*let indexPath = IndexPath(row: 0, section: index)
                    guard let cell = recipeTableView.dataSource?.tableView(recipeTableView,
                                                                         cellForRowAt: indexPath) as? RecipeTableViewCell
                        else {
                            self.showToast(message: ErrorView.systemError)
                            return
                    }
                    
                    
                    cell.modifyCell(recipe: recipeItem)*/
                    recipeTableView.beginUpdates()
                    recipeTableView.reloadSections([index], with: .automatic)
                    recipeTableView.endUpdates()
                }
                break
            }
        }
    }
    
    private func removeCell(recipe: Recipe) {
        guard let recipeTableView = self.recipeTableView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        for (index, recipeItem) in allRecipes.enumerated() {
            if recipe == recipeItem {
                allRecipes.remove(at: index)
                if allRecipes.count + 1 == recipesForShow.count {
                    recipesForShow.remove(at: index)
                    //let indexPath = IndexPath(row: 0, section: index)
                    recipeTableView.beginUpdates()
                    recipeTableView.reloadSections([index], with: .automatic)
                    recipeTableView.endUpdates()
                }
                break
            }
        }
    }
}

extension RecipeTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SystemValues.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SystemValues.recipeCellIdentifier,
                                                       for: indexPath) as? RecipeTableViewCell,
            let currentUsername = currentUsername
            else {
                let cell = RecipeTableViewCell()
                return cell
        }
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let recipe = recipesForShow[indexPath.section]
        let isFavorite = recipe.whoseFavorites.contains(currentUsername) ? true : false
        let isRated = recipe.whoRated.contains(currentUsername) ? true : false
        if let imageData = recipeImages[recipe.id] {
            cell.configure(with: recipe, isFavorite: isFavorite, isRated: isRated, image: UIImage(data: imageData), tableController: self)
        } else {
            cell.configure(with: recipe, isFavorite: isFavorite, isRated: isRated, image: nil, tableController: self)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipesForShow.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SystemValues.spaceBetweenCells
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        tableView.performBatchUpdates({
            cell.toggleIsExpanded()
        }, completion: nil)
    }
}

extension RecipeTableView {
    private func createObjectInCoreData(recipe: Recipe) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        DispatchQueue.main.async {
            viewModel.createCoreDataObject(recipe: recipe, completion: { [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleFirestoreError(error: error)
                    self.showToast(message: receivedError)
                }
            })
        }
    }
    
    private func modifyObjectInCoreData(recipe: Recipe) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        DispatchQueue.main.async {
            viewModel.updateCoreDataObject(recipe: recipe, completion: { [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleFirestoreError(error: error)
                    self.showToast(message: receivedError)
                }
            })
        }
    }
    
    private func deleteObjectFromCoreData(recipeId: String) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        DispatchQueue.main.async {
            viewModel.deleteCoreDataObject(id: recipeId, completion: { [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleFirestoreError(error: error)
                    self.showToast(message: receivedError)
                }
            })
        }
    }
    
    private func downloadFromCoreData() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.getAllCoreDataObjects(completion: { [weak self] (recipes, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            }
            guard let recipes = recipes else {
                self.showToast(message: ErrorView.nilData)
                return
            }
            self.setRecipes(recipes: recipes)
        })
    }
    
    //func for develop
    private func deleteAllCoreData(entity: String) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.deleteAllData(entity: entity, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            }
        })
    }
}
