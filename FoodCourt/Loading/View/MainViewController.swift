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
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            /*let recipeFeed = RecipeTableView()
            recipeFeed.modalPresentationStyle = .fullScreen
            present(recipeFeed, animated: true, completion: nil)*/
            
            let tabBarStoryboard = UIStoryboard(name: "TabBarController", bundle: nil)
            let vc = tabBarStoryboard.instantiateViewController(identifier: "TabBarController")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            
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

