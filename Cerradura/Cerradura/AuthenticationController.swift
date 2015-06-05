//
//  AuthenticationController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreCerraduraClient

/** Controls the Store and the UI for authentication events. */
final class AuthenticationController {
    
    // MARK: - Class Properties
    
    static let sharedController = AuthenticationController()
    
    // MARK: - Properties
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var isAuthenticated: Bool {
        
        return (self.authentication.credentials != nil)
    }
    
    // MARK: - Private Properties
    
    /** Manages storing the credentials. */
    private let authentication: Authentication = Authentication()
    
    // MARK: - Methods
    
    /** Creates a new shared store, authenticates with the server, and saves credentials. */
    func login(username: String, password: String) -> NSError? {
        
        
        
        return nil
    }
    
    func logout() {
        
        self.authentication.credentials = nil
        
        Store.removeSharedStore()
    }
}

// MARK: - Protocols

protocol AuthenticationControllerDelegate {
    
    func authenticationControllerDidLogout(controller: AuthenticationController)
}