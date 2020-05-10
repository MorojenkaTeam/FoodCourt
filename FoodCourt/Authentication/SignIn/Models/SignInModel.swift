//
//  SignInRepository.swift
//  logReg
//
//  Created by Максим Бойчук on 28.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class SignInModel: SignInModelProtocol {
    func signIn(email: String, password: String, completion: ((ErrorModel?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            if let error = error, let errorCode = AuthErrorCode(rawValue: error._code) {
                let receivedError = self.handleError(errorCode: errorCode)
                completion?(receivedError)
            } else  {
                completion?(nil)
            }
        }
    }
}

extension SignInModel {
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
        case .userDisabled:
            return ErrorModel.userDisabled
        case .operationNotAllowed:
            return ErrorModel.operationNotAllowed
        case .wrongPassword:
            return ErrorModel.wrongPassword
        default:
            return ErrorModel.unknownAuthError
        }
    }
}
