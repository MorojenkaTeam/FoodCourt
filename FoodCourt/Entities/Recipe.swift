//
//  Recipe.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

public class Recipe: Equatable {
    internal let id:             String
    internal let authorId:       String
    internal let name:           String
    internal let description:    String
    internal var image:          UIImage?
    internal var rating:         Double
    internal let ingredients:    [Ingredient]
    internal var whoseFavorites: [String]
    internal var whoRated:       [String]
    
    init(id: String, authorId: String, name: String, description: String, rating: Double, ingredients: [Ingredient],
         whoseFavorites: [String], whoRated: [String]) {
        self.id             = id
        self.authorId       = authorId
        self.name           = name
        self.description    = description
        self.rating         = rating
        self.ingredients    = ingredients
        self.whoseFavorites = whoseFavorites
        self.whoRated       = whoRated
    }
    
    public static func ==(lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
    
    func setImage(image: UIImage)                       { self.image = image }
    func setRating(rating: Double)                      { self.rating = rating }
    func setWhoRated(whoRated: [String])                { self.whoRated = whoRated }
    func setWhoseFavorites(whoseFavorites: [String])    { self.whoseFavorites = whoseFavorites }
    
    func insertFan(id: String) { whoseFavorites.append(id)}
    func removeFan(id: String) { _ = whoRated.firstIndex(of: id).map { whoRated.remove(at: $0) } }
}
