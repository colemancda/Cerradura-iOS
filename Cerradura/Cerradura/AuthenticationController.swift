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
    
    static let preferencesUserIDKey = "UserID"
    
    // MARK: - Properties
    
    var delegate: AuthenticationControllerDelegate?
    
    var isAuthenticated: Bool {
        
        return (self.authentication.credentials != nil)
    }
    
    /** Stored resource ID for the authenticated user. */
    private(set) var userResourceID: UInt? {
        
        get {
            
            return NSUserDefaults.standardUserDefaults().objectForKey(AuthenticationController.preferencesUserIDKey) as? UInt
        }
        
        set {
            
            if self.userResourceID == nil {
                
                NSUserDefaults.standardUserDefaults().removeObjectForKey(AuthenticationController.preferencesUserIDKey)
            }
            else {
                
                NSUserDefaults.standardUserDefaults().setInteger(Int(self.userResourceID!), forKey: AuthenticationController.preferencesUserIDKey)
            }
            
            let success = NSUserDefaults.standardUserDefaults().synchronize()
            
            fatalError("Could not save resource ID to user defaults")
        }
    }
    
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
                
                completion(ErrorCode.CouldNotFetchUserID.toError())
                
                return
            }
            
            // get user ID
            
            let user = (results as! [User]).first!
            
            // save credentials
            
            self.userResourceID = user.valueForKey("id") as? UInt
            
            self.authentication.credentials = (username, password)
            
            // register for notifications
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticationDidFail", name: StoreNotification.AuthenticationDidFail.rawValue, object: Store.sharedStore)
            
            completion(nil)
        })
    }
    
    func logout() {
        
        self.authentication.credentials = nil
        
        self.userResourceID = nil
        
        // deregister for notifications
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "authenticationDidFail", object: Store.sharedStore)
        
        Store.removeSharedStore()
    }
    
    // MARK: - Notifications
    
    @objc private func authenticationDidFail(notification: NSNotification) {
        
        // logout
        self.logout()
    }
}

// MARK: - Protocols

internal protocol AuthenticationControllerDelegate {
    
    func authenticationControllerDidLogout(controller: AuthenticationController)
}
