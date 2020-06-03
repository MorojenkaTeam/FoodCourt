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
    private let db: Firestore = Firestore.firestore()
    private let storage: StorageReference = Storage.storage().reference()
    private let auth: Auth = Auth.auth()
    
    func downloadRecipes(completion: (([Recipe]?, ErrorModel?) -> Void)?) {
        db.collection(Collections.recipes).getDocuments() { [weak self] (querySnapshot, error) in
            guard let self = self else {
                completion?(nil, ErrorModel.aborted)
                return
            }
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
    
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorModel?) -> Void)?) {
        let imageRef = storage.child(Collections.recipes + "/" + id + ".jpg")
        imageRef.getData(maxSize: 500 * 500 /*335 * 152*/, completion: { [weak self] (data, error) in
            guard let self = self else {
                completion?(nil, ErrorModel.aborted)
                return
            }
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
        guard let user = auth.currentUser, let username = user.displayName else {
            completion?(ErrorModel.aborted)
            return
        }
        let recipeRef = db.collection(Collections.recipes).document(id)
        if changeFlag {
            recipeRef.updateData([
                Fields.recipeWhoseFavorites: FieldValue.arrayUnion([username])
            ]) { [weak self] (error) in
                guard let self = self else {
                    completion?(ErrorModel.aborted)
                    return
                }
                if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                    let receivedError = self.handleFirestoreError(errorCode: errorCode)
                    completion?(receivedError)
                } else {
                    completion?(nil)
                }
            }
        } else {
            recipeRef.updateData([
                Fields.recipeWhoseFavorites: FieldValue.arrayRemove([username])
            ]) { [weak self] (error) in
                guard let self = self else {
                    completion?(ErrorModel.aborted)
                    return
                }
                if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                    let receivedError = self.handleFirestoreError(errorCode: errorCode)
                    completion?(receivedError)
                } else {
                    completion?(nil)
                }
            }
        }
    }
    
    func uploadRatingChanges(id: String, receivedRating: Double, completion: ((ErrorModel?) -> Void)?) {
        guard let user = auth.currentUser, let username = user.displayName else {
            completion?(ErrorModel.aborted)
            return
        }
        let recipeRef = db.collection(Collections.recipes).document(id)
        recipeRef.getDocument { [weak self] (document, error) in
            guard let self = self else {
                completion?(ErrorModel.aborted)
                return
            }
            if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                let receivedError = self.handleFirestoreError(errorCode: errorCode)
                completion?(receivedError)
                return
            }
            if let document = document, document.exists {
                guard let rating = document.get(Fields.recipeRating) as? Double,
                    let whoRated = document.get(Fields.recipeWhoRated) as? [String] else {
                    completion?(ErrorModel.objectNotFound)
                    return
                }
                var newRating = receivedRating
                if !whoRated.isEmpty {
                    let dividend = Double(whoRated.count) * rating + receivedRating
                    let divider = Double(whoRated.count + 1)
                    newRating = dividend / divider
                }
                recipeRef.updateData([
                    Fields.recipeRating: newRating,
                    Fields.recipeWhoRated: FieldValue.arrayUnion([username])
                ]) { [weak self] (error) in
                    guard let self = self else {
                        completion?(ErrorModel.objectNotFound)
                        return
                    }
                    if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                        let receivedError = self.handleFirestoreError(errorCode: errorCode)
                        completion?(receivedError)
                    } else {
                        completion?(nil)
                    }
                }
            } else {
                completion?(ErrorModel.notFound)
            }
        }
    }
    
    func observeRealtimeRecipeUpdates(completion: ((Recipe?, FirestoreDocumentChangeType?, ErrorModel?) -> Void)?) {
        db.collection(Collections.recipes).addSnapshotListener { [weak self] (querySnapshot, error) in
            if let snapshot = querySnapshot {
                snapshot.documentChanges.forEach { [weak self] (change) in
                    guard let self = self else {
                        completion?(nil, nil, ErrorModel.aborted)
                        return
                    }
                    if let recipe = self.convertToRecipe(document: change.document) {
                        switch change.type {
                        case .added:
                            print(".added")
                            completion?(recipe, FirestoreDocumentChangeType.added, nil)
                        case .modified:
                            print(".modified")
                            completion?(recipe, FirestoreDocumentChangeType.modified, nil)
                        case .removed:
                            print(".removed")
                            completion?(recipe, FirestoreDocumentChangeType.removed, nil)
                        }
                    }
                }
            } else {
                completion?(nil, nil, ErrorModel.aborted)
            }
        }
    }
}

extension RecipeTableModel {
    private func getRecipes(documents: [QueryDocumentSnapshot]) -> [Recipe] {
        var recipes = [Recipe]()
        for document in documents {
            if let recipe = convertToRecipe(document: document) {
                recipes.append(recipe)
            }
        }
        return recipes
    }
    
    private func convertToRecipe(document: QueryDocumentSnapshot) -> Recipe? {
        let documentData = document.data()
        var recipe: Recipe?
        if let recipeAuthorId = documentData[Fields.recipeAuthorId] as? String,
            let recipeName = documentData[Fields.recipeName] as? String,
            let recipeDescription = documentData[Fields.recipeDescription] as? String,
            let recipeRating = documentData[Fields.recipeRating] as? Double,
            let ingredientsMap = documentData[Fields.recipeIngredients] as? [[String: String]],
            let whoseFavorites = documentData[Fields.recipeWhoseFavorites] as? [String],
            let whoRated = documentData[Fields.recipeWhoRated] as? [String] {
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
            let recipeId = document.documentID
            let receivedRecipe = Recipe(id: recipeId, authorId: recipeAuthorId, name: recipeName, description: recipeDescription, rating: recipeRating, ingredients: ingredients, whoseFavorites: whoseFavorites, whoRated: whoRated)
            recipe = receivedRecipe
        }
        return recipe
    }
    
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
