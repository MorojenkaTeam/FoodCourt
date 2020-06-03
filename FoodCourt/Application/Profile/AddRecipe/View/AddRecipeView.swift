//
//  AddRecipeView.swift
//  FoodCourt
//
//  Created by Anton Chumakov on 24.05.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import UIKit

class AddRecipeView: UIViewController {
    @IBOutlet private weak var stackView: UIStackView?
    @IBOutlet private weak var photoView: UIView?
    @IBOutlet private weak var nameAndDescriptionView: UIView?
    @IBOutlet private weak var ingredientsView: UIView?
    @IBOutlet private weak var ingredientsList: UITableView?
    @IBOutlet private weak var nameIngredient: UITextField?
    @IBOutlet private weak var amountIngredient: UITextField?
    @IBOutlet private weak var measureIngredient: UITextField?
    @IBOutlet private weak var nameRecipe: UITextField?
    @IBOutlet private weak var descriptionRecipe: UITextView?
    @IBOutlet private weak var recipePhoto: UIImageView?
    @IBOutlet private weak var addButton: UIButton?
    @IBOutlet private weak var cancelButton: UIButton?
    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var scrollingView: UIView?
    @IBOutlet private weak var errorLabel: UILabel?
    
    private var viewModel: AddRecipeViewModel?
    private var activeTextField: UITextField?
    private var ingredients : [Ingredient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let errorLabel = errorLabel, let stackView = stackView, let scrollingView = scrollingView,
            let photoView = photoView, let nameAndDescriptionView = nameAndDescriptionView,
            let ingredientsView = ingredientsView, let addButton = addButton, let cancelButton = cancelButton,
            let ingredientsList = ingredientsList
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        errorLabel.alpha = 0
        scrollingView.addSubview(stackView)
        
        [photoView, nameAndDescriptionView, ingredientsView, addButton].forEach { $0.clipsToBounds = true }
        [photoView, nameAndDescriptionView, ingredientsView].forEach { $0.layer.cornerRadius = 16 }
        addButton.layer.cornerRadius = addButton.bounds.height/2
        cancelButton.layer.cornerRadius = cancelButton.bounds.height/2
        
        ingredientsList.dataSource = self
        ingredientsList.delegate = self
        ingredientsList.register(UINib(nibName: SystemValues.ingredientCellIdentifier, bundle: nil), forCellReuseIdentifier: SystemValues.ingredientCellIdentifier)
        viewModel = AddRecipeViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let scrollView = scrollView else { return }
        scrollView.contentInset.bottom = 0
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        choosePhoto()
    }
    
    @IBAction func addIngredient(_ sender: Any) {
        guard let nameIngredient = nameIngredient, let amountIngredient = amountIngredient,
            let measureIngredient = measureIngredient, let nameIngredientText = nameIngredient.text,
            let amountIngredientText = amountIngredient.text, let measureIngredientText = measureIngredient.text,
            let amount = Int(amountIngredientText), let ingredientsList = ingredientsList
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        ingredients.append(Ingredient(name: nameIngredientText, amount: amount, measure: measureIngredientText))
        ingredientsList.reloadData()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addRecipe(_ sender: Any) {
        guard let viewModel = viewModel, let nameRecipe = nameRecipe, let descriptionRecipe = descriptionRecipe,
            let nameRecipeText = nameRecipe.text, let descriptionRecipeText = descriptionRecipe.text,
            let recipePhoto = recipePhoto, let recipePhotoImage = recipePhoto.image
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        let whoseFavorites: [String] = [], whoRated: [String] = []
        
        let recipe: Recipe = Recipe(id: UUID().uuidString, authorId: "", name: nameRecipeText, description: descriptionRecipeText, rating: 0, ingredients: ingredients, whoseFavorites: whoseFavorites, whoRated: whoRated)
        var photo: UIImage = recipePhotoImage
        photo = UIImage.resize(image: photo, targetSize: CGSize(width: 335, height: 152))
        photo = UIImage(data: photo.jpegData(compressionQuality: 0)!, scale: photo.scale)!
        recipe.setImage(image: photo)
        
        viewModel.addRecipe(recipe: recipe, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                self.showToast(message: receivedError)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
}

extension AddRecipeView {
    private func handleFirestoreError(error: ErrorViewModel) -> String {
        switch error {
        case .cancelledFirestoreError:
            return ErrorView.cancelledFirestoreError
        case .invalidArgumentFirestoreError:
            return ErrorView.invalidArgumentFirestoreError
        case .deadlineExceeded:
            return ErrorView.deadlineExceeded
        case .notFound:
            return ErrorView.notFound
        case .alreadyExists:
            return ErrorView.alreadyExists
        case .permissionDenied:
            return ErrorView.permissionDenied
        case .resourceExhausted:
            return ErrorView.resourceExhausted
        case .failedPrecondition:
            return ErrorView.failedPrecondition
        case .aborted:
            return ErrorView.aborted
        case .outOfRange:
            return ErrorView.outOfRange
        case .unimplemented:
            return ErrorView.unimplemented
        case .`internal`:
            return ErrorView.`internal`
        case .unavailable:
            return ErrorView.unavailable
        case .dataLoss:
            return ErrorView.dataLoss
        case .unauthenticatedFirestoreError:
            return ErrorView.unauthenticatedFirestoreError
        default:
            return ErrorView.unknownFirestoreError
        }
    }
    
    private func handleStorageError(error: ErrorViewModel) -> String {
        switch error {
        case .objectNotFound:
            return ErrorView.objectNotFound
        case .bucketNotFound:
            return ErrorView.bucketNotFound
        case .projectNotFound:
            return ErrorView.projectNotFound
        case .quotaExceeded:
            return ErrorView.quotaExceeded
        case .unauthenticatedStorageError:
            return ErrorView.unauthenticatedStorageError
        case .unauthorized:
            return ErrorView.unauthorized
        case .retryLimitExceeded:
            return ErrorView.retryLimitExceeded
        case .nonMatchingChecksum:
            return ErrorView.nonMatchingChecksum
        case .downloadSizeExceeded:
            return ErrorView.downloadSizeExceeded
        case .cancelledStorageError:
            return ErrorView.cancelledStorageError
        case .invalidArgumentStorageError:
            return ErrorView.invalidArgumentStorageError
        default:
            return ErrorView.unknownStorageError
        }
    }
    
    private func showToast(message: String) {
        guard let errorLabel = errorLabel else {
            print("error label is null")
            return
        }
        errorLabel.textAlignment = .center
        errorLabel.text = message
        errorLabel.alpha = 1.0
        errorLabel.layer.cornerRadius = 16;
        errorLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 4.0, delay: 4.0, options: .curveEaseOut, animations: {
            errorLabel.alpha = 0.0
        })
    }
}

extension UIImage {
    class func resizeTo(image: UIImage, targetSize: CGSize) -> UIImage? {
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
        
        return newImage
    }
    
    class func scaleTo(image: UIImage, by scale: CGFloat) -> UIImage? {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SystemValues.ingredientCellIdentifier,
                                                       for: indexPath) as? IngredientTableViewCell else {
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
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let recipePhoto = recipePhoto else {
                self.showToast(message: ErrorView.systemError)
                print("wtf")
                return
            }
            recipePhoto.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddRecipeView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let activeTextField = activeTextField else {
            self.showToast(message: ErrorView.systemError)
            return true
        }
        activeTextField.resignFirstResponder()
        self.activeTextField = nil
        return true
    }
}

extension AddRecipeView {
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let hideKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardFunc))
        guard let scrollView = scrollView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        scrollView.addGestureRecognizer(hideKeyboard)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        guard let info = notification.userInfo,
            let keyboardRect: CGRect = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let scrollView = scrollView, let activeTextField = activeTextField
            else {
                self.showToast(message: ErrorView.systemError)
                return
        }
        let keyboardSize = keyboardRect.size
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        let scrollPoint = CGPoint(x: 0, y: activeTextField.frame.origin.y - keyboardSize.height)
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        guard let scrollView = scrollView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
    }
    
    @objc private func hideKeyboardFunc() {
        guard let scrollView = scrollView else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        scrollView.endEditing(true)
    }
}
