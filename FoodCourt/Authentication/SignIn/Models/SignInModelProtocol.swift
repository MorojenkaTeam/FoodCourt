//
//  SignInModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

protocol SignInModelProtocol {
    func signIn(email: String, password: String, completion: ((String?, ErrorModel?) -> Void)?)
}

