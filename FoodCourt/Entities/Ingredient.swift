//
//  Ingredient.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 03.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

public struct Ingredient {
    let name: String
    let amount: Int
    
    init(name: String, amount: Int) {
        self.name = name
        self.amount = amount
    }
}
