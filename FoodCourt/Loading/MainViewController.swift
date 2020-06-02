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
            let tabBarStoryboard = UIStoryboard(name: SystemValues.TabBarControllerClass, bundle: nil)
            let controller = tabBarStoryboard.instantiateViewController(identifier: SystemValues.TabBarControllerClass)
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

