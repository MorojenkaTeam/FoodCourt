//
//  AddRecipeModel.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 27.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import Firebase

class AddRecipeModel {
    private let db: Firestore?
    private let storage: StorageReference?
    private let auth: Auth

    init() {
        db = Firestore.firestore()
        storage = Storage.storage().reference()
        auth = Auth.auth()
    }
    
    func addRecipe(recipe: Recipe) {
        guard let authorId = auth.currentUser?.displayName else {return}
        var recipe = recipe
        recipe.setAuthorId(authorId: authorId)
        
        guard let db = db else {return}
        
        var completion: ((ErrorModel?) -> Void)?
            db.collection(Collections.recipes).document(recipe.getId()).setData([
                Fields.recipeId: recipe.getId(),
                Fields.recipeAuthotId: recipe.getAuthorId(),
                Fields.recipeName: recipe.getName(),
                Fields.recipeDescription: recipe.getDescription(),
                Fields.recipeRationg: recipe.getRating(),
                Fields.recipeIngredients: makeIngredientsMap(ingredients: recipe.getIngredients())
            ])  { [weak self] (error) in
                       guard let self = self else { return }
                       if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                           let receivedError = self.handleError(errorCode: errorCode)
                           completion?(receivedError)
                       } else {
                           guard let changeRequest = self.auth.currentUser?.createProfileChangeRequest() else { return }
                        changeRequest.displayName = recipe.getId()
                           changeRequest.commitChanges { [weak self] (error) in
                               guard let self = self else { return }
                               if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                                   let receivedError = self.handleError(errorCode: errorCode)
                                   completion?(receivedError)
                               } else {
                                   completion?(nil)
                               }
                           }

                       }
                   }
            guard let storage = storage else { return }
            let imageRef = storage.child(Collections.recipes + "/" + recipe.getId() + ".jpg")
            imageRef.putData((recipe.getImage()?.jpegData(compressionQuality: 0))!)
    }
        
    private func handleError(errorCode: AuthErrorCode) -> ErrorModel {
        switch errorCode {
        case .networkError:
            return ErrorModel.networkError
        case .tooManyRequests:
            return ErrorModel.tooManyRequests
        case .invalidAPIKey:
            return ErrorModel.invalidAPIKey
        case .appNotAuthorized:
            return ErrorModel.appNotAuthorized
        case .keychainError:
            return ErrorModel.keychainError
        case .internalError:
            return ErrorModel.internalError
        case .invalidEmail:
            return ErrorModel.invalidEmail
        case .emailAlreadyInUse:
            return ErrorModel.emailAlreadyInUse
        case .operationNotAllowed:
            return ErrorModel.operationNotAllowed
        case .weakPassword:
            return ErrorModel.weakPassword
        default:
            return ErrorModel.unknownAuthError
        }
    }
    
    func makeIngredientsMap(ingredients: [Ingredient]) -> [[String: String]] {
        var ingredientsMap = [[String: String]]()
        for ingredient in ingredients {
            var ingredientMap = [String: String]()
            ingredientMap[Fields.ingredientName] = ingredient.getName()
            ingredientMap[Fields.ingredientAmount] = String(ingredient.getAmount())
            ingredientMap[Fields.ingredientMeasure] = ingredient.getMeasure()
            ingredientsMap.append(ingredientMap)
        }
        return ingredientsMap
    }
}
