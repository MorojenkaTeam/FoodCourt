//
//  TabBarController.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 14.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    private let recipeFeed = RecipeTableView()
    private let profile = ProfileView()
    private var currentUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let currentUsername = currentUsername else { return }
        recipeFeed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "book.fill"), tag: 1)
        recipeFeed.setUsername(username: currentUsername)
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        
        self.viewControllers = [recipeFeed, profile]
        self.selectedIndex = 0
    }
    
    func setUsername(username: String) {
        currentUsername = username
    }
}
