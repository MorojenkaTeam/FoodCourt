//
//  SignUpViewController.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 29.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class SignUpView: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField?
    @IBOutlet weak var lastNameTextField: UITextField?
    @IBOutlet weak var usernameTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField?
    @IBOutlet weak var passwordTextField: UITextField?
    @IBOutlet weak var repeatedPasswordTextField: UITextField?
    @IBOutlet weak var errorLabel: UILabel?
    
    private var viewModel: SignUpViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel?.alpha = 0
        viewModel = SignUpViewModel()
    }
    
    private func checkDataAndGetUser(firstName: String, lastName: String, username: String, email: String,
                                     password: String, repeatedPassword: String) -> (User?, String?) {
        if firstName == "" || lastName == "" || username == "" || email == "" || password == "" ||
            password != repeatedPassword {
            return (nil, ErrorView.notValid)
        } else {
            let user = User(username: username, firstName: firstName, lastName: lastName)
            return (user, nil)
        }
    }
    
    @IBAction private func signUpButton(_ sender: Any) {
        guard let firstName = firstNameTextField?.text else { return }
        guard let lastName = lastNameTextField?.text else { return }
        guard let username = usernameTextField?.text else { return }
        guard let email = emailTextField?.text else { return }
        guard let password = passwordTextField?.text else { return }
        guard let repeatedPassword = repeatedPasswordTextField?.text else { return }
        
        let checked = checkDataAndGetUser(firstName: firstName, lastName: lastName, username: username, email: email, password: password, repeatedPassword: repeatedPassword)
        if checked.1 != nil {
            errorLabel?.text = checked.1
            errorLabel?.alpha = 1
        } else {
            guard let user = checked.0 else { return }
            viewModel?.signUp(email: email, password: password, user: user, completion: { [weak self] (error) in
                if let err = error {
                    let receivedError = self?.handleError(error: err)
                    self?.errorLabel?.text = receivedError
                    self?.errorLabel?.alpha = 1
                } else {
                    let signInView = SignInView()
                    signInView.modalPresentationStyle = .fullScreen
                    self?.present(signInView, animated: true, completion: nil)
                }
            })
        }
    }
}

extension SignUpView {
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
        case .emailAlreadyInUse:
            return ErrorView.emailAlreadyInUse
        case .operationNotAllowed:
            return ErrorView.operationNotAllowed
        case .weakPassword:
            return ErrorView.weakPassword
        default:
            return ErrorView.unknownError
        }
    }
}
