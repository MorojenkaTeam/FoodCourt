//
//  Fields.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

struct Fields {
    //user
    public static let firstName: String = "firstName"
    public static let lastName: String = "lastName"
    public static let favorites: String = "favorites"
    
    //recipe
    public static let recipeId: String = "id"
    public static let recipeAuthotId: String = "authorId"
    public static let recipeName: String = "name"
    public static let recipeDescription: String = "description"
    public static let recipeRationg: String = "rating"
    public static let recipeIngredients: String = "ingredients"
    
    //ingredient
    public static let ingredientName: String = "name"
    public static let ingredientAmount: String = "amount"
    public static let ingredientMeasure: String = "measure"
}
