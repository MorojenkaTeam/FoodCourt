//
//  IngredientTableViewCell.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBOutlet weak var info: UILabel?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        guard let info = info else {return}
        info.text = nil
    }
    
    func configure(with ingredient: Ingredient) {
        guard let info = info else {return}
        info.text = ingredient.getName() + " " + String(ingredient.getAmount()) + " " + ingredient.getMeasure()
    }
}
