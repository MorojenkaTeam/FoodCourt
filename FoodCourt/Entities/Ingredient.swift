//
//  Ingredient.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 03.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

public struct Ingredient {
    internal let name:       String
    internal let amount:     Int
    internal let measure:    String
    
    init(name: String, amount: Int, measure: String) {
        self.name       = name
        self.amount     = amount
        self.measure    = measure
    }
}
