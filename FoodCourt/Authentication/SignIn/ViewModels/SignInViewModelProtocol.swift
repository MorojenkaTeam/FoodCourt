//
//  SignInViewModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 02.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

protocol SignInViewModelProtocol {
    func signIn(email: String, password: String, completion: ((String?, ErrorViewModel?) -> Void)?)
}
