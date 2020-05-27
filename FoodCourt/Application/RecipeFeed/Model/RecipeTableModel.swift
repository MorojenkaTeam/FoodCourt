//
//  RecipeTableModel.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import Firebase

class RecipeTableModel: RecipeTableModelProtocol {
    private let db: Firestore?
    private let storage: StorageReference?
    private let auth: Auth
    
    init() {
        db = Firestore.firestore()
        storage = Storage.storage().reference()
        auth = Auth.auth()
    }
    
    func downloadRecipes(completion: (([Recipe]?, ErrorModel?) -> Void)?) {
        guard let db = db else { return }
        db.collection(Collections.recipes).getDocuments() { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                let receivedError = self.handleFirestoreError(errorCode: errorCode)
                completion?(nil, receivedError)
            } else {
                if let querySnapshot = querySnapshot {
                    let recipes = self.getRecipes(documents: querySnapshot.documents)
                    completion?(recipes, nil)
                }
            }
        }
    }
    
    /*func downloadFavorites(completion: (([String]?, ErrorModel?) -> Void)?) {
        guard let user = auth.currentUser, let username = user.displayName, let db = db else { return }
        db.collection(Collections.users).document(username).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                let receivedError = self.handleFirestoreError(errorCode: errorCode)
                completion?(nil, receivedError)
            } else {
                if let document = document, document.exists {
                    if let userData = document.data(), let favorites = userData[Fields.favorites] as? [String] {
                        completion?(favorites, nil)
                    } else {
                        completion?(nil, ErrorModel.notFound)
                    }
                } else {
                    completion?(nil, ErrorModel.notFound)
                }
            }
        }
    }*/
    
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorModel?) -> Void)?) {
        guard let storage = storage else { return }
        let imageRef = storage.child(Collections.recipes + "/" + id + ".jpg")
        imageRef.getData(maxSize: 335 * 152, completion: { [weak self] (data, error) in
            guard let self = self else { return }
            if let error = error, let errorCode = StorageErrorCode(rawValue: error._code) {
                let receivedError = self.handleStorageError(errorCode: errorCode)
                print(error.localizedDescription)
                completion?(nil, receivedError)
            } else {
                completion?(data, nil)
            }
        })
    }
    
    func uploadFavoritesChanges(id: String, changeFlag: Bool, completion: ((ErrorModel?) -> Void)?) {
        guard let user = auth.currentUser, let username = user.displayName, let db = db else { return }
        let recipeRef = db.collection(Collections.recipes).document(id)
        if changeFlag {
            recipeRef.updateData([
                Fields.whoseFavorites: FieldValue.arrayUnion([username])
            ]) { [weak self] (error) in
                guard let self = self else { return }
                if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                    let receivedError = self.handleFirestoreError(errorCode: errorCode)
                    completion?(receivedError)
                } else {
                    completion?(nil)
                }
            }
        } else {
            recipeRef.updateData([
                Fields.whoseFavorites: FieldValue.arrayRemove([username])
            ]) { [weak self] (error) in
                guard let self = self else { return }
                if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                    let receivedError = self.handleFirestoreError(errorCode: errorCode)
                    completion?(receivedError)
                } else {
                    completion?(nil)
                }
            }
        }
    }
}

extension RecipeTableModel {
    private func getRecipes(documents: [QueryDocumentSnapshot]) -> [Recipe] {
        var recipes = [Recipe]()
        //var n = documents.count
        for document in documents {
            let documentData = document.data()
            if let recipeAuthorId = documentData[Fields.recipeAuthotId] as? String,
                let recipeName = documentData[Fields.recipeName] as? String,
                let recipeDescription = documentData[Fields.recipeDescription] as? String,
                let recipeRating = documentData[Fields.recipeRationg] as? Double,
                let ingredientsMap = documentData[Fields.recipeIngredients] as? [[String: String]],
                let whoseFavorites = documentData[Fields.whoseFavorites] as? [String],
                let whoRated = documentData[Fields.whoRated] as? [String] {
                var ingredients = [Ingredient]()
                for ingredientMap in ingredientsMap {
                    if let ingredientName = ingredientMap[Fields.ingredientName],
                        let ingredientAmountString = ingredientMap[Fields.ingredientAmount],
                        let ingredientAmount = Int(ingredientAmountString),
                        let ingredientMesure = ingredientMap[Fields.ingredientMeasure] {
                        let ingredient = Ingredient(name: ingredientName, amount: ingredientAmount, measure: ingredientMesure)
                        ingredients.append(ingredient)
                    } else {
                        break
                    }
                }
                if ingredients.count == ingredientsMap.count {
                    let recipeId = document.documentID
                    let recipe = Recipe(id: recipeId, authorId: recipeAuthorId, name: recipeName, description: recipeDescription, rating: recipeRating, ingredients: ingredients, whoseFavorites: whoseFavorites, whoRated: whoRated)
                    recipes.append(recipe)
                    
                    
                    /*downloadRecipeImage(id: recipeId, completion: { [weak self] (imageData, error) in
                        guard let self = self else { return }
                        if let error = error {
                            //...
                        } else {
                            
                        }
                    })*/
                    
                }
            }
        }
        return recipes
    }
    
    /*private func readinessCheck(completion: (([Recipe]?, ErrorModel?) -> Void)?) {
        
    }*/
    
    private func handleFirestoreError(errorCode: FirestoreErrorCode) -> ErrorModel {
        switch errorCode {
        case .cancelled:
            return ErrorModel.cancelledFirestoreError
        case .invalidArgument:
            return ErrorModel.invalidArgumentFirestoreError
        case .deadlineExceeded:
            return ErrorModel.deadlineExceeded
        case .notFound:
            return ErrorModel.notFound
        case .alreadyExists:
            return ErrorModel.alreadyExists
        case .permissionDenied:
            return ErrorModel.permissionDenied
        case .resourceExhausted:
            return ErrorModel.resourceExhausted
        case .failedPrecondition:
            return ErrorModel.failedPrecondition
        case .aborted:
            return ErrorModel.aborted
        case .outOfRange:
            return ErrorModel.outOfRange
        case .unimplemented:
            return ErrorModel.unimplemented
        case .`internal`:
            return ErrorModel.`internal`
        case .unavailable:
            return ErrorModel.unavailable
        case .dataLoss:
            return ErrorModel.dataLoss
        case .unauthenticated:
            return ErrorModel.unauthenticatedFirestoreError
        default:
            return ErrorModel.unknownFirestoreError
        }
    }
    
    private func handleStorageError(errorCode: StorageErrorCode) -> ErrorModel {
        switch errorCode {
        case .objectNotFound:
            return ErrorModel.objectNotFound
        case .bucketNotFound:
            return ErrorModel.bucketNotFound
        case .projectNotFound:
            return ErrorModel.projectNotFound
        case .quotaExceeded:
            return ErrorModel.quotaExceeded
        case .unauthenticated:
            return ErrorModel.unauthenticatedStorageError
        case .unauthorized:
            return ErrorModel.unauthorized
        case .retryLimitExceeded:
            return ErrorModel.retryLimitExceeded
        case .nonMatchingChecksum:
            return ErrorModel.nonMatchingChecksum
        case .downloadSizeExceeded:
            return ErrorModel.downloadSizeExceeded
        case .cancelled:
            return ErrorModel.cancelledStorageError
        case .invalidArgument:
            return ErrorModel.invalidArgumentStorageError
        default:
            return ErrorModel.unknownStorageError
        }
    }
}
