//
//  RatingAlert.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 28.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class RatingAlert: UIViewController {
    @IBOutlet private weak var alertView: UIView?
    @IBOutlet private weak var ratingView: CosmosView?
    
    private var tableController: RecipeTableView?
    private var tableCell: RecipeTableViewCell?
    private var recipeId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let alertView = alertView, let ratingView = ratingView else { return }
        alertView.layer.cornerRadius = 20
        alertView.clipsToBounds = true
        ratingView.settings.fillMode = .precise
        ratingView.settings.filledImage = UIImage(named: SystemValues.imageStarFillName)?
            .withRenderingMode(.alwaysOriginal)
        ratingView.settings.emptyImage = UIImage(named: SystemValues.imageStarName)?
            .withRenderingMode(.alwaysOriginal)
        ratingView.settings.fillMode = .full
    }
    
    @IBAction func doRate(_ sender: UIButton) {
        guard let tableController = tableController, let tableCell = tableCell, let recipeId = recipeId,
            let ratingView = ratingView
            else { return }
        tableCell.toggleIsRated()
        tableController.uploadRatingChanges(id: recipeId, receivedRating: ratingView.rating, cell: tableCell)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setTableController(tableController: RecipeTableView) {
        self.tableController = tableController
    }
    
    func setRecipeId(recipeId: String) {
        self.recipeId = recipeId
    }
    
    func setTableCell(cell: RecipeTableViewCell) {
        self.tableCell = cell
    }
}
