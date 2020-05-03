//
//  SignUpRepository.swift
//  logReg
//
//  Created by Максим Бойчук on 28.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class SignUpModel: SignUpModelProtocol {
    private let db: Firestore
    
    init() {
        db = Firestore.firestore()
    }
    
    func checkUsernameAndSignUp(email: String, password: String, user: User, completion: ((ErrorModel?) -> Void)?) {
        guard let username = user.username else { return }
        db.collection(Collections.users).document(username).getDocument { [weak self] (document, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                let err = self?.handleError(errorCode: errorCode)
                completion?(err)
            } else if let document = document, document.exists {
                completion?(ErrorModel.usernameAlreadyInUse)
            } else {
                self?.signUp(email: email, password: password, user: user, completion: completion)
            }
        }
    }
}

extension SignUpModel {
    private func signUp(email: String, password: String, user: User, completion: ((ErrorModel?) -> Void)?) {
        guard let firstName = user.firstName, let lastName = user.lastName, let username = user.username else {
            completion?(ErrorModel.nilUserData)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                let err = self?.handleError(errorCode: errorCode)
                completion?(err)
            } else  {
                self?.setUserData(firstName: firstName, lastName: lastName, username: username, completion: completion)
            }
        }
    }
    
    private func setUserData(firstName: String, lastName: String, username: String,
                             completion: ((ErrorModel?) -> Void)?) {
        self.db.collection(Collections.users).document(username).setData([
            Fields.firstName: firstName,
            Fields.lastName: lastName
        ]) { [weak self] (error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                let err = self?.handleError(errorCode: errorCode)
                completion?(err)
            } else {
                self?.setUsernameAsDisplayName(username: username, completion: completion)
            }
        }
    }
    
    private func setUsernameAsDisplayName(username: String, completion: ((ErrorModel?) -> Void)?) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { [weak self] (error) in
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                let err = self?.handleError(errorCode: errorCode)
                completion?(err)
            } else {
                completion?(nil)
            }
        }
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
            return ErrorModel.unknownError
        }
    }
}
