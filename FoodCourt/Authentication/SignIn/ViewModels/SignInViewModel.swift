//
//  SignInViewModel.swift
//  logReg
//
//  Created by Максим Бойчук on 28.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import Foundation
import UIKit

class SignInViewModel: SignInViewModelProtocol {
    private let signInModel: SignInModel
    
    init() {
        signInModel = SignInModel()
    }
    
    func signIn(email: String, password: String, completion: ((ErrorViewModel?) -> Void)?) {
        signInModel.signIn(email: email, password: password, completion: { (error) in
            if let err = error {
                completion?(self.handleError(error: err))
            } else {
                completion?(nil)
            }
        })
    }
}

extension SignInViewModel {
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
        case .userDisabled:
            return ErrorViewModel.userDisabled
        case .operationNotAllowed:
            return ErrorViewModel.operationNotAllowed
        case .wrongPassword:
            return ErrorViewModel.wrongPassword
        default:
            return ErrorViewModel.unknownError
        }
    }
}
