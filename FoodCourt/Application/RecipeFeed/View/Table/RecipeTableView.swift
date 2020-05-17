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
    private var recipes = [Recipe]()
    private var viewModel: RecipeTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeTableView?.dataSource = self
        recipeTableView?.delegate = self
        viewModel = RecipeTableViewModel()
        recipeTableView?.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
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

extension RecipeTableView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableCellConfig.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecipeTableViewCell else {
            let cell = RecipeTableViewCell()
            return cell
        }
        
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let recipe = recipes[indexPath.section]
        cell.configure(with: recipe)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableCellConfig.height
    }
    
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
}
