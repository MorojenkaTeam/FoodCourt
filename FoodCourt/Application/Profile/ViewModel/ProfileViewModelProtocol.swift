//
//  ProfileViewModelProtocol.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 01.06.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileViewModelProtocol {
    func getUserInfo(completion: ((User?, ErrorViewModel?) -> Void)?)
    func setUserPhoto(photo: UIImage, completion: ((ErrorViewModel?) -> Void)?)
    func downloadUserPhoto(completion: ((Data?, ErrorViewModel?) -> Void)?)
    func signOut(completion: ((ErrorViewModel?) -> Void)?)
}
