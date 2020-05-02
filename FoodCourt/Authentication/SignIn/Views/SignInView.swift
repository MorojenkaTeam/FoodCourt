//
//  LoginViewController.swift
//  logReg
//
//  Created by Ума Мирзоева on 11.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import UIKit

class SignInView: UIViewController {
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var errorLabel: UILabel?
    
    private var viewModel: SignInViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel?.alpha = 0
        viewModel = SignInViewModel()
    }
    
    @IBAction func signInButton(_ sender: Any) {
        guard let email = emailTextField?.text else { return }
        guard let password = passwordTextField?.text else { return }
        
        viewModel?.signIn(email: email, password: password, completion: { [weak self] (error) in
            if let err = error {
                let receivedError = self?.handleError(error: err)
                self?.errorLabel?.text = receivedError
                self?.errorLabel?.alpha = 1
            } else {
                let recipeFeed = RecipeTableView()
                recipeFeed.modalPresentationStyle = .fullScreen
                self?.present(recipeFeed, animated: true, completion: nil)
            }
        })
    }
}

extension SignInView {
    private func handleError(error: ErrorViewModel) -> String {
        switch error {
        case .networkError:
            return ErrorView.networkError
        case .tooManyRequests:
            return ErrorView.tooManyRequests
        case .invalidAPIKey:
            return ErrorView.invalidAPIKey
        case .appNotAuthorized:
            return ErrorView.appNotAuthorized
        case .keychainError:
            return ErrorView.keychainError
        case .internalError:
            return ErrorView.internalError
        case .invalidEmail:
            return ErrorView.invalidEmail
        case .userDisabled:
            return ErrorView.userDisabled
        case .operationNotAllowed:
            return ErrorView.operationNotAllowed
        case .wrongPassword:
            return ErrorView.wrongPassword
        default:
            return ErrorView.unknownError
        }
    }
}
