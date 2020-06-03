//
//  RecipeCoreData.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 29.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class RecipeCoreData: RecipeCoreDataProtocol {
    func create(recipe: Recipe, completion: ((ErrorModel?) -> Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(ErrorModel.coreDataAbort)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: SystemValues.RecipeCoreDataClass, in: context)
            else {
                completion?(ErrorModel.coreDataAbort)
                return
        }
        if !checkIfExist(id: recipe.id, completion: completion) {
            createObject(recipe: recipe, entity: entity, context: context)
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(receivedError)
        }
        completion?(nil)
    }
    
    func createMany(recipes: [Recipe], completion: ((ErrorModel?) -> Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(ErrorModel.coreDataAbort)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: SystemValues.RecipeCoreDataClass, in: context)
            else {
                completion?(ErrorModel.coreDataAbort)
                return
        }
        for recipe in recipes {
            if !checkIfExist(id: recipe.id, completion: completion) {
                createObject(recipe: recipe, entity: entity, context: context)
            }
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(receivedError)
        }
        completion?(nil)
    }
    
    private func createObject(recipe: Recipe, entity: NSEntityDescription,
                              context: NSManagedObjectContext) {
        let recipeData = NSManagedObject(entity: entity, insertInto: context)
        recipeData.setValue(recipe.id, forKey: Fields.recipeId)
        recipeData.setValue(recipe.authorId, forKey: Fields.recipeAuthorId)
        recipeData.setValue(recipe.name, forKey: Fields.recipeName)
        recipeData.setValue(recipe.description, forKey: Fields.recipeDescriptionCoreData)
        recipeData.setValue(recipe.rating, forKey: Fields.recipeRating)
        let ingredients = recipe.ingredients
        var ingredientsMap = [[String: String]]()
        for ingredient in ingredients {
            ingredientsMap.append([
                Fields.ingredientName: ingredient.name,
                Fields.ingredientAmount: String(ingredient.amount),
                Fields.ingredientMeasure: ingredient.measure
            ])
        }
        recipeData.setValue(ingredientsMap, forKey: Fields.recipeIngredients)
        recipeData.setValue(recipe.whoseFavorites, forKey: Fields.recipeWhoseFavorites)
        recipeData.setValue(recipe.whoRated, forKey: Fields.recipeWhoRated)
        if let imageData = recipe.image?.jpegData(compressionQuality: 1.0) {
            recipeData.setValue(imageData, forKey: Fields.recipeImageData)
        }
    }
    
    func get(id: String, complition: ((ErrorModel?) -> Void)?) {
        //
    }
    
    func getAll(completion: (([Recipe]?, ErrorModel?) -> Void)?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SystemValues.RecipeCoreDataClass)
        request.returnsObjectsAsFaults = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(nil, ErrorModel.coreDataAbort)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        var recipes = [Recipe]()
        do {
            let result = try context.fetch(request)
            guard let objects = result as? [NSManagedObject] else {
                completion?(nil, ErrorModel.coreDataAbort)
                return
            }
            print(objects.count)
            for object in objects  {
                guard let id = object.value(forKey: Fields.recipeId) as? String,
                    let authorId = object.value(forKey: Fields.recipeAuthorId) as? String,
                    let name = object.value(forKey: Fields.recipeName) as? String,
                    let description = object.value(forKey: Fields.recipeDescriptionCoreData) as? String,
                    let rating = object.value(forKey: Fields.recipeRating) as? Double,
                    let ingredientsMap = object.value(forKey: Fields.recipeIngredients) as? [[String: String]],
                    let whoseFavorites = object.value(forKey: Fields.recipeWhoseFavorites) as? [String],
                    let whoRated = object.value(forKey: Fields.recipeWhoRated) as? [String],
                    let imageData = object.value(forKey: Fields.recipeImageData) as? Data,
                    let image = UIImage(data: imageData) else {
                        print("Could not fetch. Breaked data for recipe.")
                        continue
                }
                print("mamba")
                var ingredients = [Ingredient]()
                for ingredientMap in ingredientsMap {
                    if let ingredientName = ingredientMap[Fields.ingredientName],
                        let ingredientAmountString = ingredientMap[Fields.ingredientAmount],
                        let ingredientAmount = Int(ingredientAmountString),
                        let ingredientMeasure = ingredientMap[Fields.ingredientMeasure] {
                        let ingredient = Ingredient(
                            name: ingredientName,
                            amount: ingredientAmount,
                            measure: ingredientMeasure
                        )
                        ingredients.append(ingredient)
                    }
                }
                let recipe = Recipe(id: id, authorId: authorId, name: name, description: description, rating: rating, ingredients: ingredients, whoseFavorites: whoseFavorites, whoRated: whoRated)
                recipe.setImage(image: image)
                recipes.append(recipe)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(nil, receivedError)
            return
        }
        completion?(recipes, nil)
        print("got")
    }
    
    func update(recipe: Recipe, completion: ((ErrorModel?) -> Void)?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SystemValues.RecipeCoreDataClass)
        request.returnsObjectsAsFaults = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(ErrorModel.coreDataAbort)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        request.predicate = NSPredicate(format: "id == %@", recipe.id)
        do {
            let object = try context.fetch(request)
            if let objectUpdate = object.first as? NSManagedObject {
                objectUpdate.setValue(recipe.whoseFavorites, forKey: Fields.recipeWhoseFavorites)
                objectUpdate.setValue(recipe.whoRated, forKey: Fields.recipeWhoRated)
                objectUpdate.setValue(recipe.rating, forKey: Fields.recipeRating)
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                    let receivedError = handleCoreDataError(error: error)
                    completion?(receivedError)
                    return
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(receivedError)
            return
        }
        completion?(nil)
    }
    
    func delete(id: String, completion: ((ErrorModel?) -> Void)?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: SystemValues.RecipeCoreDataClass)
        request.returnsObjectsAsFaults = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(ErrorModel.coreDataAbort)
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        request.predicate = NSPredicate(format: "id == %@", id)
        do {
            let object = try context.fetch(request)
            if let objectDelete = object.first as? NSManagedObject {
                context.delete(objectDelete)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(receivedError)
            return
        }
        completion?(nil)
    }
    
    //func for develop
    func deleteAllData(entity: String, completion: ((ErrorModel?) -> Void)?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let arrUsrObj = try managedContext.fetch(fetchRequest)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                managedContext.delete(usrObj)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("delete fail--", error)
        }
        
        print("delete successful")
    }
    
    private func checkIfExist(id: String, completion: ((ErrorModel?) -> Void)?) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion?(ErrorModel.coreDataAbort)
            return true
        }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: SystemValues.RecipeCoreDataClass)
        fetchRequest.fetchLimit =  1
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                return true
            } else {
                return false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            let receivedError = handleCoreDataError(error: error)
            completion?(receivedError)
            return false
        }
    }
}

extension RecipeCoreData {
    private func handleCoreDataError(error: NSError) -> ErrorModel {
        switch (error.code) {
        case NSManagedObjectValidationError:
            return ErrorModel.validationError
        case NSValidationMissingMandatoryPropertyError:
            return ErrorModel.missingMandatoryPropertyError
        case NSValidationRelationshipLacksMinimumCountError:
            return ErrorModel.relationshipLacksMinimumCountError
        case NSValidationRelationshipExceedsMaximumCountError:
            return ErrorModel.relationshipExceedsMaximumCountError
        case NSValidationRelationshipDeniedDeleteError:
            return ErrorModel.relationshipDeniedDeleteError
        case NSValidationNumberTooLargeError:
            return ErrorModel.numberTooLargeError
        case NSValidationNumberTooSmallError:
            return ErrorModel.numberTooSmallError
        case NSValidationDateTooLateError:
            return ErrorModel.dateTooLateError
        case NSValidationDateTooSoonError:
            return ErrorModel.dateTooSoonError
        case NSValidationInvalidDateError:
            return ErrorModel.invalidDateError
        case NSValidationStringTooLongError:
            return ErrorModel.stringTooLongError
        case NSValidationStringTooShortError:
            return ErrorModel.stringTooShortError
        case NSValidationStringPatternMatchingError:
            return ErrorModel.stringPatternMatchingError
        default:
            return ErrorModel.unknownCoreDataError
        }
    }
}
