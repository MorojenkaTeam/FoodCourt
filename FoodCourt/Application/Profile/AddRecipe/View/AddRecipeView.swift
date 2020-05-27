//
//  AddRecipeView.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class AddRecipeView: UIViewController {
    @IBOutlet weak var ingredientsList: UITableView?
    private var ingredients : [Ingredient] = [] //массив ингредиентов
    @IBOutlet weak var nameIngredient: UITextField?
    @IBOutlet weak var amountIngredient: UITextField?
    @IBOutlet weak var measureIngredient: UITextField?
    @IBOutlet weak var nameRecipe: UITextField?
    @IBOutlet weak var descriptionRecipe: UITextView?
    @IBOutlet weak var recipePhoto: UIImageView?
    
    private var viewModel: AddRecipeViewModel?
    
    private let db: Firestore = Firestore.firestore()
    private let auth: Auth = Auth.auth()
    private let storage: StorageReference? = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let ingredientsList = ingredientsList else {return}
        ingredientsList.dataSource = self
        ingredientsList.delegate = self
        ingredientsList.register(UINib(nibName: "IngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngredientTableViewCell")
        viewModel = AddRecipeViewModel()
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        choosePhoto()
    }
    
    var name: String = ""
    var amount: Int = 0
    var measure: String = ""

    
    
    @IBAction func addIngredient(_ sender: Any) {
        guard let nameIngredient = nameIngredient, let amountIngredient = amountIngredient, let measureIngredient = measureIngredient else {return}
        guard let nameIngredientText = nameIngredient.text, let amountIngredientText = amountIngredient.text, let measureIngredientText = measureIngredient.text else {return}
        name = nameIngredientText
        amount = toInt(s: amountIngredientText)
        measure = measureIngredientText
        ingredients.append(Ingredient(name: name, amount: amount, measure: measure))
        guard let ingredientsList = ingredientsList else {return}
        ingredientsList.reloadData()
    }
    
    @IBAction func addRecipe(_ sender: Any) {
        guard let viewModel = viewModel else {return}
    
        guard let nameRecipe = nameRecipe, let descriptionRecipe = descriptionRecipe else {return}
        guard let nameRecipeText = nameRecipe.text, let descriptionRecipeText = descriptionRecipe.text else {return}
        
        guard let recipePhoto = recipePhoto else {return}
        guard let recipePhotoImage = recipePhoto.image else {return}
        
        var recipe: Recipe = Recipe(id: UUID().description, authorId: "", name: nameRecipeText, description: descriptionRecipeText, rating: 5, ingredients: ingredients)
        var photo: UIImage = recipePhotoImage
        photo = UIImage.resize(image: photo, targetSize: CGSize(width: 335, height: 152))
        photo = UIImage(data: photo.jpegData(compressionQuality: 0)!, scale: photo.scale)!
        recipe.setImage(image: photo)
        
        viewModel.addRecipe(recipe: recipe)
        dismiss(animated: true, completion: nil)
    }
}

extension AddRecipeView {
    func toInt(s: String?) -> Int {
      var result = 0
      if let str: String = s,
        let i = Int(str) {
          result = i
      }
      return result
    }
}

extension UIImage {
    class func resize(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func scale(image: UIImage, by scale: CGFloat) -> UIImage? {
        let size = image.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return UIImage.resize(image: image, targetSize: scaledSize)
    }
}

extension AddRecipeView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientTableViewCell", for: indexPath) as? IngredientTableViewCell else {
            let cell = IngredientTableViewCell()
            return cell
        }
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        let ingredient = ingredients[indexPath.row]
        cell.configure(with: ingredient)
        
        return cell
    }
}

extension AddRecipeView: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func choosePhoto() {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let recipePhoto = recipePhoto else {return}
            recipePhoto.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}
