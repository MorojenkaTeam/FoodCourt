//
//  ProfileViewModel.swift
//  FoodCourt
//
//  Created by Andrew Zudin on 11.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewModel: ProfileViewModelProtocol {
    private let profileModel: ProfileModel = ProfileModel()
    
    func getUserInfo(completion: ((User?, ErrorViewModel?) -> Void)?) {
        profileModel.getUserInfo(completion: { [weak self] (user, error) in
            guard let self = self else {
                completion?(nil, ErrorViewModel.systemError)
                return
            }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                completion?(nil, receivedError)
            }
            guard let user = user else {
                completion?(nil, ErrorViewModel.nilUserData)
                return
            }
            completion?(user, nil)
        })
    }
    
    func setUserPhoto(photo: UIImage, completion: ((ErrorViewModel?) -> Void)?) {
        profileModel.setUserPhoto(photo: photo, completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.systemError)
                return
            }
            if let error = error {
                let receivedError = self.handleStorageError(error: error)
                completion?(receivedError)
                return
            }
            completion?(nil)
        })
    }
    
    func downloadUserPhoto(completion: ((Data?, ErrorViewModel?) -> Void)?) {
        profileModel.downloadUserPhoto(completion: { [weak self] (photo, error) in
            guard let self = self else {
                completion?(nil, ErrorViewModel.systemError)
                return
            }
            if let error = error {
                let receivedError = self.handleStorageError(error: error)
                completion?(nil, receivedError)
                return
            }
            //print(photo)
            guard let photo = photo else {
                completion?(nil, ErrorViewModel.nilUserData)
                return
            }
            completion?(photo, nil)
        })
    }
    
    func signOut(completion: ((ErrorViewModel?) -> Void)?) {
        profileModel.signOut(completion: { [weak self] (error) in
            guard let self = self else {
                completion?(ErrorViewModel.systemError)
                return
            }
            if let error = error {
                let receivedError = self.handleAuthError(error: error)
                completion?(receivedError)
                return
            }
            completion?(nil)
        })
    }
}

extension ProfileViewModel {
    func handleAuthError(error: ErrorModel) -> ErrorViewModel {
        switch error {
        case .networkError:
            return ErrorViewModel.networkError
        case .tooManyRequests:
            return ErrorViewModel.tooManyRequests
        case .invalidAPIKey:
            return ErrorViewModel.invalidAPIKey
        case .appNotAuthorized:
            return ErrorViewModel.appNotAuthorized
        case .keychainError:
            return ErrorViewModel.keychainError
        case .internalError:
            return ErrorViewModel.internalError
        case .invalidEmail:
            return ErrorViewModel.invalidEmail
        case .emailAlreadyInUse:
            return ErrorViewModel.emailAlreadyInUse
        case .operationNotAllowed:
            return ErrorViewModel.operationNotAllowed
        case .weakPassword:
            return ErrorViewModel.weakPassword
        default:
            return ErrorViewModel.unknownAuthError
        }
    }
    
    private func handleFirestoreError(error: ErrorModel) -> ErrorViewModel {
        switch error {
        case .systemError:
            return ErrorViewModel.systemError
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
        case .systemError:
            return ErrorViewModel.systemError
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
