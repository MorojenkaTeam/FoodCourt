//
//  RecipeTableViewModel.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RecipeTableViewModel: RecipeTableViewModelProtocol {
    private var feedModel: RecipeTableModel = RecipeTableModel()
    private var feedCoreData: RecipeCoreData = RecipeCoreData()
}
    
extension RecipeTableViewModel {
    func downloadRecipes(completion: (([Recipe]?, ErrorViewModel?) -> Void)?) {
        feedModel.downloadRecipes(completion: { [weak self] (recipes, error) in
            guard let self = self else {
                completion?(nil, ErrorViewModel.aborted)
                return
            }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                completion?(nil, receivedError)
            } else {
                completion?(recipes, nil)
            }
        })
    }
    
    func downloadRecipeImage(id: String, completion: ((Data?, ErrorViewModel?) -> Void)?) {
        feedModel.downloadRecipeImage(id: id, completion: { [weak self] (data, error) in
            guard let self = self else {
                completion?(nil, ErrorViewModel.aborted)
                return
            }
            if let error = error {
                let receivedError = self.handleStorageError(error: error)
                completion?(nil, receivedError)
            } else {
                completion?(data, nil)
            }
        })
    }
    
    func uploadFavoritesChanges(id: String, changeFlag: Bool, completion: ((ErrorViewModel?) -> Void)?) {
        feedModel.uploadFavoritesChanges(id: id, changeFlag: changeFlag, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.aborted)
                return
            }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    func uploadRatingChanges(id: String, receivedRating: Double, completion: ((ErrorViewModel?) -> Void)?) {
        feedModel.uploadRatingChanges(id: id, receivedRating: receivedRating, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.aborted)
                return
            }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    func observeRealtimeRecipeUpdates(completion: ((Recipe?, FirestoreDocumentChangeType?, ErrorViewModel?) -> Void)?) {
        feedModel.observeRealtimeRecipeUpdates(completion: { [weak self] (recipe, changeType, error) in
            guard let self = self else {
                completion?(nil, nil, ErrorViewModel.aborted)
                return
            }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                completion?(nil, nil, receivedError)
            } else {
                completion?(recipe, changeType, nil)
            }
        })
    }
}

extension RecipeTableViewModel {
    func createCoreDataObject(recipe: Recipe, completion: ((ErrorViewModel?) -> Void)?) {
        feedCoreData.create(recipe: recipe, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    func createCoreDataObjects(recipes: [Recipe], completion: ((ErrorViewModel?) -> Void)?) {
        feedCoreData.createMany(recipes: recipes, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    func getAllCoreDataObjects(completion: (([Recipe]?, ErrorViewModel?) -> Void)?) {
        feedCoreData.getAll(completion: { [weak self] (recipes, error) in
            guard let self = self else {
                completion?(nil, ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(nil, receivedError)
            } else {
                completion?(recipes, nil)
            }
        })
    }
    
    func updateCoreDataObject(recipe: Recipe, completion: ((ErrorViewModel?) -> Void)?) {
        feedCoreData.update(recipe: recipe, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    func deleteCoreDataObject(id: String, completion: ((ErrorViewModel?) -> Void)?) {
        feedCoreData.delete(id: id, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
    
    //func for develop
    func deleteAllData(entity: String, completion: ((ErrorViewModel?) -> Void)?) {
        feedCoreData.deleteAllData(entity: entity, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.coreDataAbort)
                return
            }
            if let error = error {
                let receivedError = self.handleCoreDataError(error: error)
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
}

extension RecipeTableViewModel {
    private func handleFirestoreError(error: ErrorModel) -> ErrorViewModel {
        switch error {
        case .cancelledFirestoreError:
            return ErrorViewModel.cancelledFirestoreError
        case .invalidArgumentFirestoreError:
            return ErrorViewModel.invalidArgumentFirestoreError
        case .deadlineExceeded:
            return ErrorViewModel.deadlineExceeded
        case .notFound:
            return ErrorViewModel.notFound
        case .alreadyExists:
            return ErrorViewModel.alreadyExists
        case .permissionDenied:
            return ErrorViewModel.permissionDenied
        case .resourceExhausted:
            return ErrorViewModel.resourceExhausted
        case .failedPrecondition:
            return ErrorViewModel.failedPrecondition
        case .aborted:
            return ErrorViewModel.aborted
        case .outOfRange:
            return ErrorViewModel.outOfRange
        case .unimplemented:
            return ErrorViewModel.unimplemented
        case .`internal`:
            return ErrorViewModel.`internal`
        case .unavailable:
            return ErrorViewModel.unavailable
        case .dataLoss:
            return ErrorViewModel.dataLoss
        case .unauthenticatedFirestoreError:
            return ErrorViewModel.unauthenticatedFirestoreError
        default:
            return ErrorViewModel.unknownFirestoreError
        }
    }
    
    private func handleStorageError(error: ErrorModel) -> ErrorViewModel {
        switch error {
        case .objectNotFound:
            return ErrorViewModel.objectNotFound
        case .bucketNotFound:
            return ErrorViewModel.bucketNotFound
        case .projectNotFound:
            return ErrorViewModel.projectNotFound
        case .quotaExceeded:
            return ErrorViewModel.quotaExceeded
        case .unauthenticatedStorageError:
            return ErrorViewModel.unauthenticatedStorageError
        case .unauthorized:
            return ErrorViewModel.unauthorized
        case .retryLimitExceeded:
            return ErrorViewModel.retryLimitExceeded
        case .nonMatchingChecksum:
            return ErrorViewModel.nonMatchingChecksum
        case .downloadSizeExceeded:
            return ErrorViewModel.downloadSizeExceeded
        case .cancelledStorageError:
            return ErrorViewModel.cancelledStorageError
        case .invalidArgumentStorageError:
            return ErrorViewModel.invalidArgumentStorageError
        default:
            return ErrorViewModel.unknownStorageError
        }
    }
    
    private func handleCoreDataError(error: ErrorModel) -> ErrorViewModel {
        switch error {
        case .validationError:
            return ErrorViewModel.validationError
        case .coreDataAbort:
            return ErrorViewModel.coreDataAbort
        case .missingMandatoryPropertyError:
            return ErrorViewModel.missingMandatoryPropertyError
        case .relationshipLacksMinimumCountError:
            return ErrorViewModel.relationshipLacksMinimumCountError
        case .relationshipExceedsMaximumCountError:
            return ErrorViewModel.relationshipExceedsMaximumCountError
        case .relationshipDeniedDeleteError:
            return ErrorViewModel.relationshipDeniedDeleteError
        case .numberTooLargeError:
            return ErrorViewModel.numberTooLargeError
        case .numberTooSmallError:
            return ErrorViewModel.numberTooSmallError
        case .dateTooLateError:
            return ErrorViewModel.dateTooLateError
        case .dateTooSoonError:
            return ErrorViewModel.dateTooSoonError
        case .invalidDateError:
            return ErrorViewModel.invalidDateError
        case .stringTooLongError:
            return ErrorViewModel.stringTooLongError
        case .stringTooShortError:
            return ErrorViewModel.stringTooShortError
        case .stringPatternMatchingError:
            return ErrorViewModel.stringPatternMatchingError
        default:
            return ErrorViewModel.unknownCoreDataError
        }
    }
}
