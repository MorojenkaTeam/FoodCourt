//
//  RecipeTableViewModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 07.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol RecipeTableViewModelProtocol {
    //firestore
    func downloadRecipes(completion: (([Recipe]?, ErrorViewModel?) -> Void)?)
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorViewModel?) -> Void)?)
    func uploadFavoritesChanges(id: String, changeFlag: Bool, completion: ((ErrorViewModel?) -> Void)?)
    func uploadRatingChanges(id: String, receivedRating: Double, completion: ((ErrorViewModel?) -> Void)?)
    func observeRealtimeRecipeUpdates(completion: ((Recipe?, FirestoreDocumentChangeType?, ErrorViewModel?) -> Void)?)
    
    //coredata
    func createCoreDataObject(recipe: Recipe, completion: ((ErrorViewModel?) -> Void)?)
    func createCoreDataObjects(recipes: [Recipe], completion: ((ErrorViewModel?) -> Void)?)
    func getAllCoreDataObjects(completion: (([Recipe]?, ErrorViewModel?) -> Void)?)
    func updateCoreDataObject(recipe: Recipe, completion: ((ErrorViewModel?) -> Void)?)
    func deleteCoreDataObject(id: String, completion: ((ErrorViewModel?) -> Void)?)
}
