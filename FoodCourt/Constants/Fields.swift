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
    public static let firstName:    String = "firstName"
    public static let lastName:     String = "lastName"
    
    //recipe
    public static let recipeId:                     String = "id"
    public static let recipeAuthorId:               String = "authorId"
    public static let recipeName:                   String = "name"
    public static let recipeDescription:            String = "description"
    public static let recipeDescriptionCoreData:    String = "recipeDescription"
    public static let recipeRating:                 String = "rating"
    public static let recipeIngredients:            String = "ingredients"
    public static let recipeWhoseFavorites:         String = "whoseFavorites"
    public static let recipeWhoRated:               String = "whoRated"
    public static let recipeImageData:              String = "imageData"
    
    //ingredient
    public static let ingredientName:       String = "name"
    public static let ingredientAmount:     String = "amount"
    public static let ingredientMeasure:    String = "measure"
}
