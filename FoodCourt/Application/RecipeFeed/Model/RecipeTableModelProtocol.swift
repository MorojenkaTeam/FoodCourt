//
//  RecipeTableModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 07.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol RecipeTableModelProtocol {
    func downloadRecipes(completion: (([Recipe]?, ErrorModel?) -> Void)?)
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorModel?) -> Void)?)
}
