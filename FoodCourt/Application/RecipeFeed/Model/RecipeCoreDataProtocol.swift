//
//  RecipeCoreDataProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 01.06.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol RecipeCoreDataProtocol {
    func create(recipe: Recipe, completion: ((ErrorModel?) -> Void)?)
    func createMany(recipes: [Recipe], completion: ((ErrorModel?) -> Void)?)
    func get(id: String, complition: ((ErrorModel?) -> Void)?)
    func getAll(completion: (([Recipe]?, ErrorModel?) -> Void)?)
    func update(recipe: Recipe, completion: ((ErrorModel?) -> Void)?)
    func delete(id: String, completion: ((ErrorModel?) -> Void)?)
}
