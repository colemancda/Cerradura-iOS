//
//  AuthenticationController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreCerradura
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
    
    var userResourceID: UInt?
    
    // MARK: - Private Properties
    
    /** Manages storing the credentials. */
    private let authentication: Authentication = Authentication()
    
    // MARK: - Methods
    
    /** Creates a new shared store, authenticates with the server, and saves credentials. */
    func login(username: String, password: String, server serverURL: NSURL, completion: (NSError?) -> Void) {
        
        // create store
        Store.loadSharedStore(username, password: password, server: serverURL)
        
        // try to load user profile
        
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        fetchRequest.predicate = NSPredicate(format: "username == %@", argumentArray: [username])
        
        Store.sharedStore.performSearch(fetchRequest, completionBlock: { (error, results) -> Void in
            
            if error != nil {
                
                completion(error)
                
                return
            }
            
            if results!.count == 0 {
                
                let error = NSError(domain: <#String#>, code: <#Int#>, userInfo: <#[NSObject : AnyObject]?#>)
            }
            
            // get user ID
            
            let user = (results as! [User]).first!
            
            
        })
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