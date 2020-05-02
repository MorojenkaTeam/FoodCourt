//
//  SingUpErrors.swift
//  FoodCourt
//
//  Created by Максим Бойчук on 30.04.2020.
//  Copyright © 2020 Maksim Boichuk. All rights reserved.
//

import Foundation
import UIKit

public struct ErrorView {
    //common
    public static let notValid: String = "Not all fields are filled in or passwords don't match"
    public static let networkError: String = "No internet connection"
    public static let tooManyRequests: String = "You sent too many requests"
    public static let invalidAPIKey: String = "The wrong API access key is specified, contact the developers"
    public static let appNotAuthorized: String = "The application doesn't have the right to connect to the database, " +
    "contact the developers"
    public static let keychainError: String = "An error occurred while accessing the keychain, contact the developers"
    public static let internalError: String = "An internal error occurred, contact the developers"
    public static let unknownError: String = "An unknown error occurred, contact the developers"
    
    //createUserWithEmail
    //signInWithEmail
    public static let invalidEmail: String = "You indicated an invalid email"
    public static let operationNotAllowed: String = "Email operations are disabled, contact the developers"
    
    //createUserWithEmail
    public static let emailAlreadyInUse: String = "This email is already in use"
    public static let weakPassword: String = "Your password is too weak, enter a stronger password"
    public static let usernameAlreadyInUse: String = "This username is already in use"
    
    //signInWithEmail
    public static let userDisabled: String = "Your account is disabled, contact the developers"
    public static let wrongPassword: String = "You entered the wrong password"
}

public enum ErrorViewModel {
    //common
    case networkError
    case tooManyRequests
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case unknownError
    
    //createUserWithEmail
    //signInWithEmail
    case invalidEmail
    case operationNotAllowed
    
    //createUserWithEmail
    case emailAlreadyInUse
    case weakPassword
    case usernameAlreadyInUse
    
    //signInWithEmail
    case userDisabled
    case wrongPassword
}

public enum ErrorModel {
    //common errors
    case networkError
    case tooManyRequests
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case unknownError
    
    //createUserWithEmail
    //signInWithEmail
    case invalidEmail
    case operationNotAllowed
    
    //createUserWithEmail
    case emailAlreadyInUse
    case weakPassword
    case usernameAlreadyInUse
    
    //signInWithEmail
    case userDisabled
    case wrongPassword
}
