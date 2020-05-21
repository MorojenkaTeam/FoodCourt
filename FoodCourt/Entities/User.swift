//
//  User.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

struct User {
    private var username: String
    private var firstName: String
    private var lastName: String
    
    init(username: String, firstName: String, lastName: String) {
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func getUsername() -> String { return username }
    func getFirstName() -> String { return firstName }
    func getLastName() -> String { return lastName }
}
