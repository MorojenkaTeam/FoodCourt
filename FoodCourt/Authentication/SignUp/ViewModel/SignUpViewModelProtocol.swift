//
//  SignUpViewModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol SignUpViewModelProtocol {
    func signUp(email: String, password: String, user: User, completion: ((ErrorViewModel?) -> Void)?)
}
