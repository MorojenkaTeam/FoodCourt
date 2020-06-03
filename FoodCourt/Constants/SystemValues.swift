//
//  SystemNames.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 28.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

public struct SystemValues {
    //images
    public static let imageStarName:        String = "fc.star"
    public static let imageStarFillName:    String = "fc.star.fill"
    public static let imageCapName:         String = "fc.cap"
    public static let imageCapFillName:     String = "fc.cap.fill"
    public static let imagePersonName:      String = "fc.person"
    public static let imagePersonFillName:  String = "fc.person.fill"
    public static let imageMarkName:        String = "fc.mark"
    public static let imageMarkFillName:    String = "fc.mark.fill"
    public static let imageMagnifierName:   String = "fc.magnifier"
    
    //coredata
    public static let RecipeCoreDataClass: String = "RecipeEntity"
    
    //tabbar
    public static let TabBarControllerClass: String = "TabBarController"
    
    //table cells
    public static let ingredientCellIdentifier: String  = "IngredientTableViewCell"
    public static let recipeCellIdentifier:     String  = "RecipeTableViewCell"
    public static let numberOfRowsInSection:    Int     = 1
    public static let spaceBetweenCells:        CGFloat = 30
}

public enum FirestoreDocumentChangeType {
    case added
    case modified
    case removed
}
