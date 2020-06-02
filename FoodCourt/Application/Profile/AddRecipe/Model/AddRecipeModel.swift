//
//  AddRecipeModel.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 27.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase

class AddRecipeModel {
    private let db:         Firestore          = Firestore.firestore()
    private let storage:    StorageReference   = Storage.storage().reference()
    private let auth:       Auth               = Auth.auth()
    
    func addRecipe(recipe: Recipe, completion: ((ErrorModel?) -> Void)?) {
        guard let authorId = auth.currentUser?.displayName else {
            completion?(ErrorModel.unknownAuthError)
            return
        }
        let imageRef = self.storage.child(Collections.recipes + "/" + recipe.id + ".jpg")
        guard let imageData = recipe.image?.jpegData(compressionQuality: 0) else {
            completion?(ErrorModel.dataLoss)
            return
        }
        imageRef.putData(imageData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else {
                completion?(ErrorModel.systemError)
                return
            }
            if let error = error, let errorCode = StorageErrorCode(rawValue: error._code) {
                let receivedError = self.handleStorageError(errorCode: errorCode)
                completion?(receivedError)
                return
            }
            self.db.collection(Collections.recipes).document(recipe.id).setData([
                Fields.recipeId: recipe.id,
                Fields.recipeAuthorId: authorId,
                Fields.recipeName: recipe.name,
                Fields.recipeDescription: recipe.description,
                Fields.recipeRating: recipe.rating,
                Fields.recipeWhoseFavorites: recipe.whoseFavorites,
                Fields.recipeWhoRated: recipe.whoRated,
                Fields.recipeIngredients: self.makeIngredientsMap(ingredients: recipe.ingredients)
            ])  { [weak self] (error) in
                guard let self = self else {
                    completion?(ErrorModel.systemError)
                    return
                }
                if let error = error, let errorCode =  FirestoreErrorCode(rawValue: error._code) {
                    let receivedError = self.handleFirestoreError(errorCode: errorCode)
                    completion?(receivedError)
                    return
                }
                completion?(nil)
            }
        }
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
    
    func makeIngredientsMap(ingredients: [Ingredient]) -> [[String: String]] {
        var ingredientsMap = [[String: String]]()
        for ingredient in ingredients {
            var ingredientMap = [String: String]()
            ingredientMap[Fields.ingredientName] = ingredient.name
            ingredientMap[Fields.ingredientAmount] = String(ingredient.amount)
            ingredientMap[Fields.ingredientMeasure] = ingredient.measure
            ingredientsMap.append(ingredientMap)
        }
        return ingredientsMap
    }
}
