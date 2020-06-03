//
//  AddRecipeViewModel.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 27.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

class AddRecipeViewModel {
    private var addRecipeModel: AddRecipeModel = AddRecipeModel()
    
    func addRecipe (recipe: Recipe, completion: ((ErrorViewModel?) -> Void)?) {
        addRecipeModel.addRecipe(recipe: recipe, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.systemError)
                return
            }
            if let error = error {
                var receivedError = self.handleFirestoreError(error: error)
                if receivedError == ErrorViewModel.unknownFirestoreError {
                    receivedError = self.handleStorageError(error: error)
                }
                completion?(receivedError)
            } else {
                completion?(nil)
            }
        })
    }
}

extension AddRecipeViewModel {
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
}

