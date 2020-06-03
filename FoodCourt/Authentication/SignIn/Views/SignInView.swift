//
//  LoginViewController.swift
//  logReg
//
//  Created by Ума Мирзоева on 11.04.2020.
//  Copyright © 2020 bmstu. All rights reserved.
//

import UIKit

class SignInView: UIViewController {
    @IBOutlet private weak var emailTextField: UITextField?
    @IBOutlet private weak var passwordTextField: UITextField?
    @IBOutlet private weak var errorLabel: UILabel?
    @IBOutlet private weak var signInButton: UIButton?
    @IBOutlet private weak var scrollView: UIScrollView?
    
    private var activeTextField: UITextField?
    private var viewModel: SignInViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let errorLabel = errorLabel else { return }
        errorLabel.alpha = 0
        guard let signInButton = signInButton else { return }
        signInButton.layer.cornerRadius = 20
        signInButton.clipsToBounds = true
        signInButton.layer.borderWidth = 0.5
        signInButton.layer.borderColor = UIColor.gray.cgColor
        viewModel = SignInViewModel()
        
        guard let emailTextField = emailTextField else { return }
        emailTextField.delegate = self
        emailTextField.layer.cornerRadius = 20
        emailTextField.clipsToBounds = true
        emailTextField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        
        guard let passwordTextField = passwordTextField else { return }
        passwordTextField.delegate = self
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.clipsToBounds = true
        passwordTextField.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        
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
    
    @IBAction func signInButton(_ sender: Any) {
        guard let email = emailTextField?.text,
            let password = passwordTextField?.text,
            let viewModel = viewModel else { return }
        
        viewModel.signIn(email: email, password: password, completion: { [weak self] (username, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleError(error: error)
                guard let errorLabel = self.errorLabel else { return }
                errorLabel.text = receivedError
                errorLabel.alpha = 1
            } else {
                /*let recipeFeed = RecipeTableView()
                recipeFeed.modalPresentationStyle = .fullScreen
                self.present(recipeFeed, animated: true, completion: nil)*/
                
                /*let tabBar = TabBarController()
                tabBar.modalPresentationStyle = .fullScreen
                self.present(tabBar, animated: true, completion: nil)*/
                
                /*let tabBarStoryboard = UIStoryboard(name: "TabBarController", bundle: nil)
                let vc = tabBarStoryboard.instantiateViewController(identifier: "TabBarController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)*/
                
                let tabBarStoryboard = UIStoryboard(name: "TabBarController", bundle: nil)
                let controller = tabBarStoryboard.instantiateViewController(identifier: "TabBarController")
                guard let tabBarController = controller as? TabBarController, let currentUsername = username
                    else {
                        return
                }
                tabBarController.setUsername(username: currentUsername)
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func backToSignUpButton(_ sender: Any) {
        let signUpView = SignUpView()
        signUpView.modalPresentationStyle = .fullScreen
        self.present(signUpView, animated: true, completion: nil)
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
            return ErrorView.unknownAuthError
        }
    }
}

extension SignInView: UITextFieldDelegate {
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

extension SignInView {
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
