//
//  ProfileModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 01.06.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileModelProtocol {
    func getUserInfo (completion: ((User?, ErrorModel?) -> Void)?)
    func setUserPhoto(photo: UIImage, completion: ((ErrorModel?) -> Void)?)
    func downloadUserPhoto(completion: ((Data?, ErrorModel?) -> Void)?)
    func signOut(completion: ((ErrorModel?) -> Void)?)
}
