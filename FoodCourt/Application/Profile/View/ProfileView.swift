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
    @IBOutlet private weak var profilePhoto: UIImageView?
    @IBOutlet private weak var addRecipeView: UIView?
    @IBOutlet private weak var settingsView: UIView?
    @IBOutlet private weak var userName: UILabel?
    @IBOutlet private weak var errorLabel: UILabel?
    @IBOutlet private weak var logOutBtn: UIButton?
    @IBOutlet private weak var addRecipeImage: UIImageView?
    @IBOutlet private weak var settingsImage: UIImageView?
    
    private var viewModel: ProfileViewModel?
    
    @IBAction func addRecipe(_ sender: UIButton) {
        let modalViewController = AddRecipeView()
        modalViewController.modalPresentationStyle = .overCurrentContext
        present(modalViewController, animated: true, completion: nil)
    }
    
    @IBAction func settingPush(_ sender: Any) {
        choosePhoto()
    }
    
    @IBAction func signOut(_ sender: Any) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            return
        }
        viewModel.signOut(completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleAuthError(error: error)
                self.showToast(message: receivedError)
                return
            }
            let authView = AuthView()
            authView.modalPresentationStyle = .fullScreen
            self.present(authView, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func configure() {
        guard let profilePhoto = profilePhoto, let addRecipeView = addRecipeView, let settingsView = settingsView,
            let errorLabel = errorLabel, let logOutBtn = logOutBtn, let addRecipeImage = addRecipeImage,
            let settingsImage = settingsImage
            else {
                self.showToast(message: ErrorView.systemError)
                print("here7")
                return
            }
        errorLabel.alpha = 0
        logOutBtn.layer.cornerRadius = logOutBtn.bounds.height/2
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.height/2
        profilePhoto.clipsToBounds = true
        profilePhoto.image = UIImage(named: "fc.person.fill-1")
        addRecipeView.layer.cornerRadius = addRecipeView.bounds.width/5
        addRecipeView.clipsToBounds = true
        settingsView.layer.cornerRadius = settingsView.bounds.width/5
        settingsView.clipsToBounds = true
        addRecipeImage.image = UIImage(named: "fc.scroll")
        settingsImage.image = UIImage(named: "fc.settings")
        
        viewModel = ProfileViewModel()
        downloadUserData()
        downloadUserPhoto()
    }
    
    private func downloadUserData() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            print("here1")
            return
        }
        viewModel.getUserInfo(completion: { [weak self] (user, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleFirestoreError(error: error)
                print("here2")
                self.showToast(message: receivedError)
                return
            }
            guard let user = user, let userName = self.userName else {
                self.showToast(message: ErrorView.systemError)
                print("here3")
                return
            }
            userName.text = user.firstName + "\n" + user.lastName
        })
    }
    
    private func downloadUserPhoto() {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            print("here4")
            return
        }
        viewModel.downloadUserPhoto(completion: { [weak self] (photo, error) in
            guard let self = self else { return }
            if let error = error {
                let receivedError = self.handleStorageError(error: error)
                print("here5")
                self.showToast(message: receivedError)
                return
            }
            guard let photo = photo, let profilePhoto = self.profilePhoto else {
                //self.showToast(message: ErrorView.systemError)
                print("here6")
                return
            }
            profilePhoto.image = UIImage(data: photo)
        })
    }
}

extension ProfileView: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func choosePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            guard let profilePhoto = profilePhoto else {
                self.showToast(message: ErrorView.systemError)
                print("here8")
                return
            }
            var photo: UIImage = cropImage(photo: image)
            photo = UIImage.resize(image: photo, targetSize: CGSize(width: 100, height: 100))
            photo = UIImage(data: photo.jpegData(compressionQuality: 0)!, scale: photo.scale)!
            profilePhoto.image = photo
            uploadUserPhoto(photo: photo)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func uploadUserPhoto(photo: UIImage) {
        guard let viewModel = viewModel else {
            self.showToast(message: ErrorView.systemError)
            print("here9")
            return
        }
        viewModel.setUserPhoto(photo: photo, completion: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                print("here10")
                let receivedError = self.handleStorageError(error: error)
                self.showToast(message: receivedError)
            }
        })
    }
    
    func cropImage(photo: UIImage) -> UIImage {
        let width = photo.size.width
        let height = photo.size.height
        var sideLength = CGFloat()
        if width > height { sideLength = height }
        else { sideLength = width }
        let crop = CGRect(x: (width-sideLength)/2,y: (height-sideLength)/2,width: sideLength,height: sideLength)
        let imgOrientation = photo.imageOrientation
        let imgScale = photo.scale
        let cgImage = photo.cgImage
        let croppedCGImage = cgImage!.cropping(to: crop)
        let coreImage = CIImage(cgImage: croppedCGImage!)
        let ciContext = CIContext(options: nil)
        let filteredImageRef = ciContext.createCGImage(coreImage, from: coreImage.extent)
        let finalImage = UIImage(cgImage:filteredImageRef!, scale:imgScale, orientation:imgOrientation)
        return finalImage
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
}


extension ProfileView {
    func handleAuthError(error: ErrorViewModel) -> String {
        switch error {
        case .networkError:
            return ErrorView.networkError
        case .tooManyRequests:
            return ErrorView.tooManyRequests
        case .invalidAPIKey:
            return ErrorView.invalidAPIKey
        case .appNotAuthorized:
            return ErrorView.appNotAuthorized
        case .keychainError:
            return ErrorView.keychainError
        case .internalError:
            return ErrorView.internalError
        case .invalidEmail:
            return ErrorView.invalidEmail
        case .emailAlreadyInUse:
            return ErrorView.emailAlreadyInUse
        case .operationNotAllowed:
            return ErrorView.operationNotAllowed
        case .weakPassword:
            return ErrorView.weakPassword
        default:
            return ErrorView.unknownAuthError
        }
    }
    
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
            self.showToast(message: ErrorView.systemError)
            print("here11")
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
