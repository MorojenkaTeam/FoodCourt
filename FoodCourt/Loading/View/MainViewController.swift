//
//  ViewController.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 10.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //private var username: String? = ""
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            /*let recipeFeed = RecipeTableView()
            recipeFeed.modalPresentationStyle = .fullScreen
            present(recipeFeed, animated: true, completion: nil)*/
            
            //self.username = user.displayName
            let tabBarStoryboard = UIStoryboard(name: "TabBarController", bundle: nil)
            let controller = tabBarStoryboard.instantiateViewController(identifier: "TabBarController")
            guard let tabBarController = controller as? TabBarController, let currentUsername = user.displayName
                else {
                    return
            }
            tabBarController.setUsername(username: currentUsername)
            tabBarController.modalPresentationStyle = .fullScreen
            self.present(tabBarController, animated: true, completion: nil)
            
            /*let authView = AuthView()
            authView.modalPresentationStyle = .fullScreen
            present(authView, animated: true, completion: nil)*/
        } else {
            let authView = AuthView()
            authView.modalPresentationStyle = .fullScreen
            present(authView, animated: true, completion: nil)
        }
    }
}

