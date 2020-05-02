//
//  SignUpViewModel.swift
//  logReg
//
//  Created by Максим Бойчук on 28.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import Foundation
import UIKit

class SignUpViewModel: SignUpViewModelProtocol {
    private let signUpModel: SignUpModel
    
    init() {
        signUpModel = SignUpModel()
    }
    
    func signUp(email: String, password: String, user: User, completion: ((ErrorViewModel?) -> Void)?) {
        signUpModel.checkUsernameAndSignUp(email: email, password: password, user: user, completion: {
            [weak self] (error) in
            if let err = error {
                completion?(self?.handleError(error: err))
            } else {
                completion?(nil)
            }
        })
    }
}

extension SignUpViewModel {
    private func handleError(error: ErrorModel) -> ErrorViewModel {
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
            return ErrorViewModel.unknownError
        }
    }
}

