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
    @IBOutlet private weak var firstNameTextField: UITextField?
    @IBOutlet private weak var lastNameTextField: UITextField?
    @IBOutlet private weak var usernameTextField: UITextField?
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var passwordTextField: UITextField?
    @IBOutlet private weak var repeatedPasswordTextField: UITextField?
    @IBOutlet private weak var errorLabel: UILabel?
    @IBOutlet private weak var signUpButton: UIButton?
    @IBOutlet private weak var scrollView: UIScrollView?
    
    private var activeTextField: UITextField?
    private var viewModel: SignUpViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let errorLabel = errorLabel, let signUpButton = signUpButton else { return }
        errorLabel.alpha = 0
        signUpButton.layer.cornerRadius = 20
        signUpButton.clipsToBounds = true
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.gray.cgColor
        viewModel = SignUpViewModel()
        buttonsDesign();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let scrollView = scrollView else { return }
        scrollView.contentInset.bottom = 0
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
        guard let firstName = firstNameTextField?.text, let lastName = lastNameTextField?.text,
            let username = usernameTextField?.text, let email = emailTextField?.text,
            let password = passwordTextField?.text, let repeatedPassword = repeatedPasswordTextField?.text else { return }
        let checked = checkDataAndGetUser(firstName: firstName, lastName: lastName, username: username, email: email, password: password, repeatedPassword: repeatedPassword)
        if checked.1 != nil {
            guard let errorLabel = errorLabel else { return }
            errorLabel.text = checked.1
            errorLabel.alpha = 1
        } else {
            guard let user = checked.0, let viewModel = viewModel else { return }
            viewModel.signUp(email: email, password: password, user: user, completion: { [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    let receivedError = self.handleError(error: error)
                    guard let errorLabel = self.errorLabel else { return }
                    errorLabel.text = receivedError
                    errorLabel.alpha = 1
                } else {
                    let signInView = SignInView()
                    signInView.modalPresentationStyle = .fullScreen
                    self.present(signInView, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func backToSignInButton(_ sender: Any) {
        let signInView = SignInView()
        signInView.modalPresentationStyle = .fullScreen
        self.present(signInView, animated: true, completion: nil)
    }
    
    
    func buttonsDesign(){
        guard let firstNameTextField = firstNameTextField, let lastNameTextField = lastNameTextField,
        let usernameTextField = usernameTextField, let emailTextField = emailTextField,
        let passwordTextField = passwordTextField,
        let repeatedPasswordTextField = repeatedPasswordTextField else { return }
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatedPasswordTextField.delegate = self
        
        for textField in [firstNameTextField, emailTextField, passwordTextField] {
            textField.layer.cornerRadius = 20
            textField.clipsToBounds = true
            textField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            textField.layer.borderWidth = 0.5
            textField.layer.borderColor = UIColor.gray.cgColor
        }
        
        for textField in [lastNameTextField, usernameTextField, repeatedPasswordTextField] {
            textField.layer.cornerRadius = 20
            textField.clipsToBounds = true
            textField.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            textField.layer.borderWidth = 0.5
            textField.layer.borderColor = UIColor.gray.cgColor
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
            return ErrorView.unknownAuthError
        }
    }
}

extension SignUpView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let activeTextField = activeTextField else { return true }
        activeTextField.resignFirstResponder()
        self.activeTextField = nil
        return true
    }
}

extension SignUpView {
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardFunc))
        guard let scrollView = scrollView else { return }
        scrollView.addGestureRecognizer(hideKeyboard)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let info = notification.userInfo,
            let keyboardRect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardSize = keyboardRect.size
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        guard let scrollView = scrollView else { return }
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        guard let activeTextField = activeTextField else { return }
        //let visible_screen_when_keyboard_appeared = self.view.bounds.height - keyboardSize.height
        //let activeFieldFrame = scrollView?.convert(activeTextField.frame, to: nil)
        let scrollPoint = CGPoint(x: 0, y: activeTextField.frame.origin.y - keyboardSize.height)
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        guard let scrollView = scrollView else { return }
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func hideKeyboardFunc() {
        guard let scrollView = scrollView else { return }
        scrollView.endEditing(true)
    }
}
