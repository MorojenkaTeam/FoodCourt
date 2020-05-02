//
//  File.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Cosmos

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeNameLabel: UILabel?
    @IBOutlet weak var recipeDescriptionLabel: UILabel?
    @IBOutlet weak var recipeImageView: UIImageView?
    @IBOutlet weak var recipeCosmosView: CosmosView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        recipeNameLabel?.text = nil
        recipeDescriptionLabel?.text = nil
        recipeImageView?.image = nil
    }
    
    func configure(with recipe: Recipe) {
        recipeNameLabel?.text = recipe.name
        recipeDescriptionLabel?.text = recipe.description
        
        //let imageBytes = recipe.imageData
        //let imageData = NSData(bytes: imageBytes, length: imageBytes.count)
        //let image = UIImage(data: imageData as Data)
        //recipeImageView?.image = image
        
        let imageUrl = URL(string: recipe.imageData)
        //recipeImageView?.image?.resizingMode = 
        recipeImageView?.kf.setImage(with: imageUrl)
        recipeImageView?.contentMode = .scaleAspectFill
        recipeImageView?.clipsToBounds = true
        recipeCosmosView?.settings.fillMode = .precise
        recipeCosmosView?.rating = recipe.rating
    }
}
