//
//  RecipeTableViewModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 07.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol RecipeTableViewModelProtocol {
    func downloadRecipes(completion: (([Recipe]?, ErrorViewModel?) -> Void)?)
}
