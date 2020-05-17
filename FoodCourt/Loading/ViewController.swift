//
//  ViewController.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 16.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            let recipeFeed = RecipeTableView()
            recipeFeed.modalPresentationStyle = .fullScreen
            present(recipeFeed, animated: true, completion: nil)
        } else {
            print("HERE1")
            let authView = AuthView()
            authView.modalPresentationStyle = .fullScreen
            present(authView, animated: true, completion: nil)
        }
    }
}

