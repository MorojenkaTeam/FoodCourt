//
//  IngredientTableViewCell.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    @IBOutlet weak var info: UILabel?
    
    override func prepareForReuse() {
        guard let info = info else {return}
        info.text = nil
    }
    
    func configure(with ingredient: Ingredient) {
        guard let info = info else {return}
        info.text = ingredient.name + " " + String(ingredient.amount) + " " + ingredient.measure
    }
}
