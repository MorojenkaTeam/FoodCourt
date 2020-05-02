//
//  RecipeTableViewModel.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

class RecipeTableViewModel {
    private var tableModel: RecipeTableModel?
    
    init() {
        tableModel = RecipeTableModel()
    }
    
    func loadRecipes(completion: (([Recipe]?) -> Void)?) {
        tableModel?.loadRecipes(completion: { (recipes) in
            completion?(recipes)
        })
    }
}
