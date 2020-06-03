//
//  ProfileModel.swift
//  FoodCourt
//
//  Created by Andrew Zudin on 11.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase

class ProfileModel: ProfileModelProtocol {
    private let db: Firestore = Firestore.firestore()
    private let storage: StorageReference = Storage.storage().reference()
    private let auth: Auth = Auth.auth()
    
    func getUserInfo(completion: ((User?, ErrorModel?) -> Void)?) {
        guard let username = auth.currentUser?.displayName else {
            completion?(nil, ErrorModel.nilUserData)
            return
        }
        db.collection(Collections.users).document(username).getDocument { [weak self] (document, error) in
            guard let self = self else {
                completion?(nil, ErrorModel.systemError)
                return
            }
            if let error = error, let errorCode = FirestoreErrorCode(rawValue: error._code) {
                let receivedError = self.handleFirestoreError(errorCode: errorCode)
                completion?(nil, receivedError)
                return
            }
            if let document = document, document.exists {
                if let userData = document.data(), let firstName = userData[Fields.firstName] as? String,
                    let lastName = userData[Fields.lastName] as? String {
                    let user = User(username: username, firstName: firstName, lastName: lastName)
                    completion?(user, nil)
                } else {
                    completion?(nil, ErrorModel.dataLoss)
                }
                return
            }
            completion?(nil, ErrorModel.notFound)
        }
    }
    
    func setUserPhoto(photo: UIImage, completion: ((ErrorModel?) -> Void)?) {
        guard let username = auth.currentUser?.displayName else {
            completion?(ErrorModel.nilUserData)
            return
        }
        let imageRef = storage.child(Collections.users + "/" + username + ".jpg")
        guard let imageData = photo.jpegData(compressionQuality: 0) else {
            completion?(ErrorModel.systemError)
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
            }
            completion?(nil)
        }
    }
    
    func downloadUserPhoto(completion: ((Data?, ErrorModel?) -> Void)?) {
        guard let username = auth.currentUser?.displayName else {
            completion?(nil, ErrorModel.nilUserData)
            return
        }
        let imageRef = storage.child(Collections.users + "/" + username + ".jpg")
        imageRef.getData(maxSize: 150 * 150, completion: { [weak self] (data, error) in
            guard let self = self else {
                completion?(nil, ErrorModel.systemError)
                return
            }
            if let error = error, let errorCode = StorageErrorCode(rawValue: error._code) {
                //print("WTF lol")
                let receivedError = self.handleStorageError(errorCode: errorCode)
                print(error.localizedDescription)
                completion?(nil, receivedError)
            } else {
                completion?(data, nil)
            }
        })
    }
    
    func signOut(completion: ((ErrorModel?) -> Void)?) {
        do {
            try auth.signOut()
        } catch let error as NSError {
            print(error)
            print(error.localizedDescription)
            completion?(ErrorModel.unknownAuthError)
        }
        completion?(nil)
    }
}

extension ProfileModel {
    func handleAuthError(errorCode: AuthErrorCode) -> ErrorModel {
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
    
    func handleFirestoreError(errorCode: FirestoreErrorCode) -> ErrorModel {
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
