//
//  AddRecipeViewModel.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 27.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

class AddRecipeViewModel {
    private var addRecipeModel: AddRecipeModel?

    init() {
        addRecipeModel = AddRecipeModel()
    }
    
    func addRecipe (recipe: Recipe) {
        guard let addRecipeModel = addRecipeModel else {return}
        addRecipeModel.addRecipe(recipe: recipe)
    }
}
