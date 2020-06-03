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
    @IBOutlet private weak var recipeNameLabel: UILabel?
    @IBOutlet private weak var recipeDescriptionLabel: UILabel?
    @IBOutlet private weak var recipeImageView: UIImageView?
    @IBOutlet private weak var ingredientsStackView: UIStackView?
    @IBOutlet private weak var recipeCosmosView: CosmosView?
    @IBOutlet private weak var bookmarkImageView: UIImageView?
    @IBOutlet private weak var numberOfRatings: UILabel?
    @IBOutlet private weak var numberOfFans: UILabel?
    @IBOutlet private weak var rateButton: UIButton?
    
    @IBOutlet private weak var collapsedConstraint: NSLayoutConstraint?
    @IBOutlet private weak var expandedConstraint: NSLayoutConstraint?
    
    private var recipeId: String?
    private var tableController: RecipeTableView?
    private var isFavorite: Bool = false {
        didSet {
            let bookMarkName: String = isFavorite ? SystemValues.imageMarkFillName : SystemValues.imageMarkName
            guard let tableController = tableController else {
                print("Ooops. somewhere in cell tableController is nil.")
                return
            }
            guard let bookmarkImageView = bookmarkImageView else {
                tableController.showToast(message: ErrorView.systemError)
                return
            }
            bookmarkImageView.image = UIImage(named: bookMarkName)?.withRenderingMode(.alwaysOriginal)
        }
    }
    private var isRated: Bool = false {
        didSet {
            guard let tableController = tableController else {
                print("Ooops. somewhere in cell tableController is nil.")
                return
            }
            guard let rateButton = rateButton else {
                tableController.showToast(message: ErrorView.systemError)
                return
            }
            DispatchQueue.main.async {
                if self.isRated {
                    rateButton.setTitleColor(.systemGreen, for: .normal)
                    rateButton.setTitle("Rated ✓", for: .normal)
                    rateButton.isUserInteractionEnabled = false
                } else {
                    rateButton.setTitleColor(.systemBlue, for: .normal)
                    rateButton.setTitle("Rate", for: .normal)
                    rateButton.isUserInteractionEnabled = true
                }
            }
        }
    }
    private var isExpanded: Bool = false {
        didSet {
            guard let tableController = tableController else {
                print("Ooops. somewhere in cell tableController is nil.")
                return
            }
            guard let collapsedConstraint = collapsedConstraint, let expandedConstraint = expandedConstraint
                else {
                    tableController.showToast(message: ErrorView.systemError)
                    return
            }
            expandedConstraint.priority = isExpanded ? .defaultHigh : .defaultLow
            collapsedConstraint.priority = isExpanded ? .defaultLow : .defaultHigh
        }
    }
    
    @IBAction func doRate(_ sender: UIButton) {
        guard let tableController = tableController else {
            print("Ooops. somewhere in cell tableController is nil.")
            return
        }
        guard let recipeId = recipeId else {
            tableController.showToast(message: ErrorView.systemError)
            return
        }
        let ratingAlert = RatingAlert()
        ratingAlert.modalPresentationStyle = .overCurrentContext
        ratingAlert.setTableController(tableController: tableController)
        ratingAlert.setTableCell(cell: self)
        ratingAlert.setRecipeId(recipeId: recipeId)
        tableController.present(ratingAlert, animated: true, completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        guard let tableController = tableController else {
            print("Ooops. somewhere in cell tableController is nil.")
            return
        }
        guard let recipeImageView = recipeImageView, let ingredientsStackView = ingredientsStackView
            else {
                tableController.showToast(message: ErrorView.systemError)
                return
        }
        recipeImageView.image = nil
        ingredientsStackView.clean()
        recipeId = nil
        self.backgroundColor = nil
    }
    
    func configure(with recipe: Recipe, isFavorite: Bool, isRated: Bool, image: UIImage?,
                   tableController: RecipeTableView) {
        self.tableController = tableController
        guard let recipeNameLabel = recipeNameLabel, let recipeDescriptionLabel = recipeDescriptionLabel,
            let recipeImageView = recipeImageView, let recipeCosmosView = recipeCosmosView,
            let ingredientsStackView = ingredientsStackView, let bookmarkImageView = bookmarkImageView,
            let numberOfRatings = numberOfRatings, let numberOfFans = numberOfFans
            else {
                tableController.showToast(message: ErrorView.systemError)
                return
        }
        
        recipeId = recipe.id
        recipeNameLabel.text = recipe.name
        recipeDescriptionLabel.text = recipe.description
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.layer.cornerRadius = 16
        recipeImageView.clipsToBounds = true
        if image != nil {
            recipeImageView.image = image
        } else if let existingImage = recipe.image {
            recipeImageView.image = existingImage
        }
        recipeCosmosView.settings.fillMode = .precise
        recipeCosmosView.settings.filledImage = UIImage(named: SystemValues.imageStarFillName)?
            .withRenderingMode(.alwaysOriginal)
        recipeCosmosView.settings.emptyImage = UIImage(named: SystemValues.imageStarName)?
            .withRenderingMode(.alwaysOriginal)
        recipeCosmosView.rating = recipe.rating
        recipeCosmosView.isUserInteractionEnabled = false
        
        let ingredients = recipe.ingredients
        setIngredients(ingredients: ingredients, ingredientsStackView: ingredientsStackView)
        
        let clicked = UITapGestureRecognizer(target: self, action: #selector(bookmarkClicked))
        bookmarkImageView.isUserInteractionEnabled = true
        bookmarkImageView.addGestureRecognizer(clicked)
        self.isFavorite = isFavorite
        
        self.isRated = isRated
        let whoRated = recipe.whoRated
        numberOfRatings.text = whoRated.isEmpty ? "no ratings" : "(\(whoRated.count))"
        numberOfFans.text = "x \(recipe.whoseFavorites.count)"
    }
    
    private func setIngredients(ingredients: [Ingredient], ingredientsStackView: UIStackView) {
        for ingredient in ingredients {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fill
            ingredientsStackView.addArrangedSubview(stackView)
            stackView.leadingAnchor.constraint(equalTo: ingredientsStackView.leadingAnchor,
                                               constant: 0.0).isActive = true
            stackView.trailingAnchor.constraint(equalTo: ingredientsStackView.trailingAnchor,
                                                constant: 0.0).isActive = true
            
            let nameLabel = UILabel()
            nameLabel.text = ingredient.name
            nameLabel.lineBreakMode = .byWordWrapping
            nameLabel.contentMode = .left
            nameLabel.numberOfLines = 0
            let ellipsisLabel = UILabel()
            ellipsisLabel.text = ""
            let amountAndMeasureLabel = UILabel()
            amountAndMeasureLabel.text = String(ingredient.amount) + " " + ingredient.measure
            amountAndMeasureLabel.contentMode = .left
            for label in [nameLabel, ellipsisLabel, amountAndMeasureLabel] {
                label.font = UIFont(name: "Montserrat-Medium", size: 14)
                stackView.addArrangedSubview(label)
            }
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 0.0),
                nameLabel.trailingAnchor.constraint(equalTo: ellipsisLabel.leadingAnchor, constant: 0.0),
                nameLabel.widthAnchor.constraint(
                    equalToConstant: nameLabel.intrinsicContentSize.width),
                amountAndMeasureLabel.leadingAnchor.constraint(equalTo: ellipsisLabel.trailingAnchor, constant: 0.0),
                amountAndMeasureLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0.0),
                amountAndMeasureLabel.widthAnchor.constraint(
                    equalToConstant: amountAndMeasureLabel.intrinsicContentSize.width)
            ])
            stackView.layoutIfNeeded()
            
            while ellipsisLabel.intrinsicContentSize.width <= ellipsisLabel.frame.width {
                ellipsisLabel.text?.append(".")
            }
        }
        ingredientsStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func bookmarkClicked() {
        guard let tableController = tableController else {
            print("Ooops. somewhere in cell tableController is nil.")
            return
        }
        guard let recipeId = recipeId else {
            tableController.showToast(message: ErrorView.systemError)
            return
        }
        isFavorite.toggle()
        tableController.uploadFavoritesChanges(recipeId: recipeId, changeFlag: isFavorite, cell: self)
    }
}

extension RecipeTableViewCell {
    func toggleIsExpanded() { isExpanded.toggle() }
    func toggleIsRated() { isRated.toggle() }
    func toggleIsFavorite() { isFavorite.toggle() }
    
    func setImage(image: UIImage) {
        guard let tableController = tableController else {
            print("Ooops. somewhere in cell tableController is nil.")
            return
        }
        guard let recipeImageView = recipeImageView else {
            tableController.showToast(message: ErrorView.systemError)
            return
        }
        recipeImageView.image = image
    }
    
    /*func modifyCell(recipe: Recipe) {
        recipeCosmosView?.rating = recipe.getRating()
        let whoRated = recipe.getWhoRated()
        numberOfRatings?.text = whoRated.isEmpty ? "no ratings" : "(\(whoRated.count))"
        numberOfFans?.text = "x \(recipe.getWhoseFavorites().count)"
    }*/
}

extension UIStackView {
    private func removeChild(view: UIView) {
        removeArrangedSubview(view)
        view.removeFromSuperview()
    }
    
    func clean() {
        arrangedSubviews.forEach { (view) in
            removeChild(view: view)
        }
    }
}
