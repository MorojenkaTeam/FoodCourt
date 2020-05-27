//
//  ProfileView.swift
//  FoodCourt
//
//  Created by Andrew Zudin on 07.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit
import Foundation

class ProfileView: UIViewController {
    
    @IBOutlet weak var profilePhoto: UIImageView?
    @IBOutlet weak var textBase: UIView?
    
    private var viewModel: ProfileViewModel?
    
    @IBAction func addRecipe(_ sender: UIButton) {
        let modalViewController = AddRecipeView()
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let profilePhoto = profilePhoto, let textBase = textBase else {return}
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.height/2
        textBase.layer.cornerRadius = textBase.bounds.width/5
        profilePhoto.addConstraint(NSLayoutConstraint(
            item: profilePhoto,
            attribute: NSLayoutConstraint.Attribute(rawValue: 126)!,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: profilePhoto,
            attribute: NSLayoutConstraint.Attribute(rawValue: 126)!,
            multiplier: 1,
            constant: 0)
        )
        viewModel = ProfileViewModel()
    }
}
