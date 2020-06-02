//
//  RecipeTableModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 07.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol RecipeTableModelProtocol {
    func downloadRecipes(completion: (([Recipe]?, ErrorModel?) -> Void)?)
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorModel?) -> Void)?)
    func uploadFavoritesChanges(id: String, changeFlag: Bool, completion: ((ErrorModel?) -> Void)?)
    func uploadRatingChanges(id: String, receivedRating: Double, completion: ((ErrorModel?) -> Void)?)
    func observeRealtimeRecipeUpdates(completion: ((Recipe?, FirestoreDocumentChangeType?, ErrorModel?) -> Void)?)
}
