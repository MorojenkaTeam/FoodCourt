//
//  Recipe.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

public struct Recipe {
    let id: String
    let authorId: String
    let name: String
    let description: String
    //let imageData: [UInt8]
    let imageData: String
    let rating: Double
    
    init(id: String, authorId: String, name: String, description: String, imageData: String, rating: Double) {
        self.id = id
        self.authorId = authorId
        self.name = name
        self.description = description
        self.imageData = imageData
        self.rating = rating
    }
}
