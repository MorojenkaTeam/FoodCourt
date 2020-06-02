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
    
    func signIn(email: String, password: String, completion: ((String?, ErrorViewModel?) -> Void)?) {
        signInModel.signIn(email: email, password: password, completion: { [weak self] (username, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleError(error: error)
                completion?(nil, receivedError)
            } else {
                completion?(username, nil)
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
            return ErrorViewModel.unknownAuthError
        }
    }
}
