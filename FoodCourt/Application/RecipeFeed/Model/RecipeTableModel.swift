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
    
    init() {
        db = Firestore.firestore()
        storage = Storage.storage().reference()
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
}

extension RecipeTableModel {
    private func getRecipes(documents: [QueryDocumentSnapshot]) -> [Recipe] {
        var recipes = [Recipe]()
        for document in documents {
            let documentData = document.data()
            if let recipeAuthorId = documentData[Fields.recipeAuthotId] as? String,
                let recipeName = documentData[Fields.recipeName] as? String,
                let recipeDescription = documentData[Fields.recipeDescription] as? String,
                let recipeRating = documentData[Fields.recipeRationg] as? Double,
                let ingredientsMap = documentData[Fields.recipeIngredients] as? [[String: String]] {
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
                //print(ingredientsMap.count)
                if ingredients.count == ingredientsMap.count {
                    let recipeId = document.documentID
                    let recipe = Recipe(id: recipeId, authorId: recipeAuthorId, name: recipeName, description: recipeDescription, rating: recipeRating, ingredients: ingredients)
                    recipes.append(recipe)
                }
            }
        }
        return recipes
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
