//
//  TabBarController.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 14.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController/*, UITabBarDelegate*/ {
    let favorites = FavoritesView()
    let recipeFeed = RecipeTableView()
    let profile = ProfileView()
    override func viewDidLoad() {
        super.viewDidLoad()
        /*self.title = "item"
        self.tabBarItem.image = UIImage(named: "item")
        self.tabBarItem.selectedImage = UIImage(named: "item_selected")*/
        configure()
    }
    
    private func configure() {
        //kee.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 2)
        //kee.tabBarItem.title = "Feed"
        //kee.tabBarItem.titleTextAttributes(for: .application)
        //kee.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(), tag: 2)
        
       /* profile.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 3)
        profile.tabBarItem.title = "Profile" */
        
        favorites.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "heart-7.png"), tag: 0)
        recipeFeed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "pizza.png"), tag: 1)
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "smiley-smile.png"), tag: 2)
        
        self.viewControllers = [favorites, recipeFeed, profile]
        self.selectedIndex = 1
    }
}
