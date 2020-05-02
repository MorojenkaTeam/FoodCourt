//
//  AuthView.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class AuthView: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func signInButton(_ sender: Any) {
        let signInView = SignInView()
        signInView.modalPresentationStyle = .fullScreen
        self.present(signInView, animated: true, completion: nil)
    }
    
    @IBAction private func signUpButton(_ sender: Any) {
        let signUpView = SignUpView()
        signUpView.modalPresentationStyle = .fullScreen
        self.present(signUpView, animated: true, completion: nil)
    }
}
