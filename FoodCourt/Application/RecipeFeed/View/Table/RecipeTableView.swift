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
    @IBOutlet weak var recipeTableView: UITableView?
    
    private let cellIdentifier = "RecipeTableViewCell"
    //private let localDatabaseManager: LocalDatabaseManager = LocalDatabaseManager.shared
    private var recipes = [Recipe]()
    private var viewModel: RecipeTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeTableView?.dataSource = self
        recipeTableView?.delegate = self
        viewModel = RecipeTableViewModel()
        self.recipeTableView?.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        viewModel?.loadRecipes { [weak self] (recipes) in
            guard let recipes = recipes else {
                return
            }
            
            self?.recipes = recipes
            DispatchQueue.main.async {
                self?.recipeTableView?.reloadData()
            }
        }
    }
}

extension RecipeTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecipeTableViewCell else {
            let cell = RecipeTableViewCell()
            return cell
        }
        
        let recipe = recipes[indexPath.row]
        cell.configure(with: recipe)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
}

extension RecipeTableView: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
