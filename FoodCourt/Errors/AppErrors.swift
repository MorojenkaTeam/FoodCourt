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
    //application
    public static let systemError: String = "Something wrong. System error occurred."
    public static let nilData: String = "Received empty data."
    
    //authentication
    public static let notValid:             String = "Not all fields are filled in or passwords don't match"
    public static let networkError:         String = "No internet connection"
    public static let tooManyRequests:      String = "You sent too many requests"
    public static let invalidAPIKey:        String = "The wrong API access key is specified, contact the developers"
    public static let appNotAuthorized:     String = "The application doesn't have the right to connect to the " + "database, contact the developers"
    public static let keychainError:        String = "An error occurred while accessing the keychain, contact the " + "developers"
    public static let internalError:        String = "An internal error occurred, contact the developers"
    public static let invalidEmail:         String = "You indicated an invalid email"
    public static let operationNotAllowed:  String = "Email operations are disabled, contact the developers"
    public static let emailAlreadyInUse:    String = "This email is already in use"
    public static let weakPassword:         String = "Your password is too weak, enter a stronger password"
    public static let usernameAlreadyInUse: String = "This username is already in use"
    public static let nilUserData:          String = "Could not recognize the entered data, try it again"
    public static let userDisabled:         String = "Your account is disabled, contact the developers"
    public static let wrongPassword:        String = "You entered the wrong password"
    public static let unknownAuthError:     String = "An unknown error occurred, contact the developers"
    
    //firestore
    public static let cancelledFirestoreError:          String = "The operation was cancelled"
    public static let invalidArgumentFirestoreError:    String = "An invalid argument was provided"
    public static let deadlineExceeded:                 String = "Deadline expired before operation could complete"
    public static let notFound:                         String = "Some requested document was not found"
    public static let alreadyExists:                    String = "Some document that we attempted to create already " + "exists"
    public static let permissionDenied:                 String = "The caller does not have permission to execute the " + "specified operation"
    public static let resourceExhausted:                String = "Some resource has been exhausted"
    public static let failedPrecondition:               String = "Operation was rejected because the system is not " +
    "in a state required for the operation’s execution"
    public static let aborted:                          String = "The operation was aborted"
    public static let outOfRange:                       String = "Operation was attempted past the valid range"
    public static let unimplemented:                    String = "Operation is not implemented or not supported/enabled"
    public static let `internal`:                       String = "An internal error occurred"
    public static let unavailable:                      String = "The service is currently unavailable"
    public static let dataLoss:                         String = "Unrecoverable data loss or corruption"
    public static let unknownFirestoreError:            String = "An unknown error occurred"
    public static let unauthenticatedFirestoreError:    String = "The request does not have valid authentication " +
    "credentials for the operation"
    
    //storage
    public static let objectNotFound:               String = "No object exists at the desired reference"
    public static let bucketNotFound:               String = "No bucket is configured for Firebase Storage"
    public static let projectNotFound:              String = "No project is configured for Firebase Storage"
    public static let quotaExceeded:                String = "Quota on your Firebase Storage bucket has been exceeded"
    public static let unauthenticatedStorageError:  String = "User is unauthenticated. Authenticate and try again"
    public static let unauthorized:                 String = "User is not authorized to perform the desired action. " + "Check your rules to ensure they are correct"
    public static let retryLimitExceeded:           String = "The maximum time limit on an operation has been " +
    "exceeded. Try again"
    public static let nonMatchingChecksum:          String = "File on the client does not match the checksum of " +
    "the file received by the server. Try again"
    public static let downloadSizeExceeded:         String = "Size of the downloaded file exceeds the amount of " +
    "memory allocated for the download. Increase memory cap and try downloading again"
    public static let cancelledStorageError:        String = "The operation was cancelled"
    public static let unknownStorageError:          String = "An unknown error occurred"
    public static let invalidArgumentStorageError:  String = "An invalid argument was provided"
    
    //coredata
    public static let validationError:                      String = "Generic validation error."
    public static let coreDataAbort:                        String = "Abort. Something is wrong."
    public static let missingMandatoryPropertyError:        String = "The attribute mustn't be empty."
    public static let relationshipLacksMinimumCountError:   String = "The relationship doesn't have enough entries."
    public static let relationshipExceedsMaximumCountError: String = "The relationship has too many entries."
    public static let relationshipDeniedDeleteError:        String = "To delete, the relationship must be empty."
    public static let numberTooLargeError:                  String = "The number of the attribute is too large."
    public static let numberTooSmallError:                  String = "The number of the attribute is too small."
    public static let dateTooLateError:                     String = "The date of the attribute is too late."
    public static let dateTooSoonError:                     String = "The date of the attribute is too soon."
    public static let invalidDateError:                     String = "The date of the attribute is invalid."
    public static let stringTooLongError:                   String = "The text of the attribute is too long."
    public static let stringTooShortError:                  String = "The text of the attribute is too short."
    public static let stringPatternMatchingError:           String = "The text of the attribute doesn't match the " + "required pattern."
    public static let unknownCoreDataError:                 String = "An unknown error occurred, contact the developers"
}

public enum ErrorViewModel {
    //application
    case systemError
    
    //authentication
    case networkError
    case tooManyRequests
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case invalidEmail
    case operationNotAllowed
    case emailAlreadyInUse
    case weakPassword
    case usernameAlreadyInUse
    case nilUserData
    case userDisabled
    case wrongPassword
    case unknownAuthError
    
    //firestore
    case cancelledFirestoreError
    case invalidArgumentFirestoreError
    case deadlineExceeded
    case notFound
    case alreadyExists
    case permissionDenied
    case resourceExhausted
    case failedPrecondition
    case aborted
    case outOfRange
    case unimplemented
    case `internal`
    case unavailable
    case dataLoss
    case unauthenticatedFirestoreError
    case unknownFirestoreError
    
    //storage
    case objectNotFound
    case bucketNotFound
    case projectNotFound
    case quotaExceeded
    case unauthenticatedStorageError
    case unauthorized
    case retryLimitExceeded
    case nonMatchingChecksum
    case downloadSizeExceeded
    case cancelledStorageError
    case unknownStorageError
    case invalidArgumentStorageError
    
    //coredata
    case validationError
    case coreDataAbort
    case missingMandatoryPropertyError
    case relationshipLacksMinimumCountError
    case relationshipExceedsMaximumCountError
    case relationshipDeniedDeleteError
    case numberTooLargeError
    case numberTooSmallError
    case dateTooLateError
    case dateTooSoonError
    case invalidDateError
    case stringTooLongError
    case stringTooShortError
    case stringPatternMatchingError
    case unknownCoreDataError
}

public enum ErrorModel {
    //application
    case systemError
    
    //authentication
    case networkError
    case tooManyRequests
    case invalidAPIKey
    case appNotAuthorized
    case keychainError
    case internalError
    case invalidEmail
    case operationNotAllowed
    case emailAlreadyInUse
    case weakPassword
    case usernameAlreadyInUse
    case nilUserData
    case userDisabled
    case wrongPassword
    case unknownAuthError
    
    //firestore
    case cancelledFirestoreError
    case invalidArgumentFirestoreError
    case deadlineExceeded
    case notFound
    case alreadyExists
    case permissionDenied
    case resourceExhausted
    case failedPrecondition
    case aborted
    case outOfRange
    case unimplemented
    case `internal`
    case unavailable
    case dataLoss
    case unauthenticatedFirestoreError
    case unknownFirestoreError
    
    //storage
    case objectNotFound
    case bucketNotFound
    case projectNotFound
    case quotaExceeded
    case unauthenticatedStorageError
    case unauthorized
    case retryLimitExceeded
    case nonMatchingChecksum
    case downloadSizeExceeded
    case cancelledStorageError
    case unknownStorageError
    case invalidArgumentStorageError
    
    //coredata
    case validationError
    case coreDataAbort
    case missingMandatoryPropertyError
    case relationshipLacksMinimumCountError
    case relationshipExceedsMaximumCountError
    case relationshipDeniedDeleteError
    case numberTooLargeError
    case numberTooSmallError
    case dateTooLateError
    case dateTooSoonError
    case invalidDateError
    case stringTooLongError
    case stringTooShortError
    case stringPatternMatchingError
    case unknownCoreDataError
}
