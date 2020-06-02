//
//  User.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

struct User {
    internal var username:   String
    internal var firstName:  String
    internal var lastName:   String
    
    init(username: String, firstName: String, lastName: String) {
        self.username   = username
        self.firstName  = firstName
        self.lastName   = lastName
    }
}
