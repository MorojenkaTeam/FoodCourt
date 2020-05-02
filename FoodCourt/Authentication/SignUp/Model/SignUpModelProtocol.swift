//
//  SignUpModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation

protocol SignUpModelProtocol {
    func checkUsernameAndSignUp(email: String, password: String, user: User, completion: ((ErrorModel?) -> Void)?)
}
