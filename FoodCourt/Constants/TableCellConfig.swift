//
//  TableCellConfig.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 03.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

public struct TableCellConfig {
    public static let recipeCellIdentifier = "RecipeTableViewCell"
    public static let filterByNameCellIdentifier = "FilterByNameTableViewCell"
    public static let filterByIngredientCellIdentifier = "FilterByIngredientTableViewCell"
    public static let filterByRatingCellIdentifier = "FilterByRatingTableViewCell"
    public static let numberOfRowsInSection: Int = 1
    //public static let height: CGFloat = 300
    public static let spaceBetweenCells: CGFloat = 30
}
