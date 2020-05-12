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
import FirebaseUI

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var recipeNameLabel: UILabel?
    @IBOutlet private weak var recipeDescriptionLabel: UILabel?
    @IBOutlet private weak var recipeImageView: UIImageView?
    @IBOutlet private weak var recipeCosmosView: CosmosView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let recipeNameLabel = recipeNameLabel, let recipeDescriptionLabel = recipeDescriptionLabel,
            let recipeImageView = recipeImageView else { return }
        recipeNameLabel.text = nil
        recipeDescriptionLabel.text = nil
        recipeImageView.image = nil
    }
    
    func configure(with recipe: Recipe) {
        guard let recipeNameLabel = recipeNameLabel, let recipeDescriptionLabel = recipeDescriptionLabel,
            let recipeImageView = recipeImageView, let recipeCosmosView = recipeCosmosView else { return }
        recipeNameLabel.text = recipe.getName()
        recipeDescriptionLabel.text = recipe.getDescription()
        //let imageUrl = URL(string: recipe.imageData)
        //recipeImageView?.kf.setImage(with: imageUrl)
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.layer.cornerRadius = 16
        recipeImageView.clipsToBounds = true
        recipeCosmosView.settings.fillMode = .precise
        recipeCosmosView.rating = recipe.getRating()
        recipeCosmosView.isUserInteractionEnabled = false
    }
    
    func setImage(image: UIImage) {
        guard let recipeImageView = recipeImageView else { return }
        recipeImageView.image = image
    }
}
