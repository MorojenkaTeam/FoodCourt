//
//  RecipeTableView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class RecipeTableView: UIViewController {
    @IBOutlet private weak var recipeTableView: UITableView?
    @IBOutlet private weak var recipeSearch: UIImageView?
    @IBOutlet private weak var errorLabel: UILabel?
    
    private var recipes = [Recipe]()
    private var viewModel: RecipeTableViewModel?
    private var rowsStates = [Bool]()
    private var favorites = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        //recipeTableView?.estimatedRowHeight = 100
        //recipeTableView?.rowHeight = UITableView.automaticDimension
        guard let errorLabel = errorLabel, let recipeTableView = recipeTableView, let recipeSearch = recipeSearch
            else { return }
        recipeTableView.dataSource = self
        recipeTableView.delegate = self
        recipeTableView.register(UINib(nibName: TableCellConfig.cellIdentifier, bundle: nil),
                                 forCellReuseIdentifier: TableCellConfig.cellIdentifier)
        
        recipeSearch.image = UIImage(systemName: "magnifyingglass")
        let clicked = UITapGestureRecognizer(target: self, action: #selector(searchClicked))
        recipeSearch.isUserInteractionEnabled = true
        recipeSearch.addGestureRecognizer(clicked)
        recipeSearch.tintColor = .black
        errorLabel.alpha = 0
        
        viewModel = RecipeTableViewModel()
        downloadRecipeData()
    }
    
    @objc func searchClicked() {
        print("search clicked")
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
                self.recipes = recipes
                DispatchQueue.main.async {
                    self.rowsStates = Array(repeating: false, count: recipes.count)
                    guard let recipeTableView = self.recipeTableView else { return }
                    recipeTableView.reloadData()
                }
                self.doanloadFavorites()
            }
        })
    }
    
    private func doanloadFavorites() {
        guard let viewModel = viewModel else { return }
        viewModel.downloadFavorites(completion: { [weak self] (favorites, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            } else {
                guard let favorites = favorites else { return }
                self.favorites = Set(favorites.map { $0 })
                
                    guard let recipeTableView = self.recipeTableView else { return }
                    for (index, recipe) in self.recipes.enumerated() {
                        if self.favorites.contains(recipe.getId()) {
                            let indexPath = IndexPath(row: 0, section: index)
                            guard let cell = recipeTableView.cellForRow(at: indexPath) as? RecipeTableViewCell
                                else { return }
                            cell.setIsFavorite(true)
                            DispatchQueue.main.async {
                                cell.setAsFavorite()
                            }
                        }
                    }
                self.downloadRecipeImages()
            }
        })
    }
 
    private func downloadRecipeImages() {
        guard let viewModel = viewModel else { return }
        for (index, recipe) in recipes.enumerated() {
            viewModel.downloadRecipeImage(id: recipe.getId(), completion: { [weak self] (data, error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleStorageError(error: error)
                    self.showToast(message: receivedError)
                } else {
                    let indexPath = IndexPath(row: 0, section: index)
                    guard let recipeTableView = self.recipeTableView, let imageData = data,
                        let image = UIImage(data: imageData),
                        let cell = recipeTableView.cellForRow(at: indexPath) as? RecipeTableViewCell else { return }
                    DispatchQueue.main.async {
                        cell.setImage(image: image)
                    }
                    self.recipes[index].setImage(image: image)
                }
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
                } else {
                    self.favorites.remove(recipeId)
                }
            }
        })
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
}

extension RecipeTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableCellConfig.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCellConfig.cellIdentifier,
                                                       for: indexPath) as? RecipeTableViewCell
            else {
                let cell = RecipeTableViewCell()
                return cell
        }
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let recipe = recipes[indexPath.section]
        cell.configure(with: recipe, tableController: self)
        if let image = recipe.getImage() {
            cell.setImage(image: image)
        }
        favorites.contains(recipe.getId()) ? cell.setAsFavorite() : cell.setAsNotFavorite()
        cell.setIsExpanded(rowsStates[indexPath.section])
        //cell.selectionStyle = .none
        return cell
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell
            else { return 10.0 }
        //print("here")
        if cell.getIsExpanded() {
            return cell.getExpandedBorder()
        } else {
            return cell.getCollapsedBorder()
        }
        
        
        //return UITableView.automaticDimension
        
        //return 150
        /*if selectedRowIndex == indexPath.section {
         return 150
         } else {
         return TableCellConfig.height
         }*/
    }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipes.count
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
        /*tableView.beginUpdates()
         if selectedRowIndex == indexPath.section {
         selectedRowIndex = -1
         } else {
         selectedRowIndex = indexPath.section
         }
         tableView.endUpdates()*/
        //print("kek")
        
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell
            else { return }
        rowsStates[indexPath.section].toggle()
        tableView.performBatchUpdates({
            cell.setIsExpanded(rowsStates[indexPath.section])
        }, completion: nil)
    }
}
