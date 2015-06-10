//
//  Authentication.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import KeychainAccess

/** Holds the information for authenticating with the server, and manages storage in the keychain. */
public final class Authentication {
    
    // MARK: - Class Properties
    
    /** Key for storing the password in the keychain. */
    public static let keychainPasswordKey = "Password"
    
    /** Key for storing the username in the keychain. */
    public static let keychainUsernameKey = "Username"
    
    // MARK: - Properties
    
    /** Username and password credentials. */
    public var credentials: (String, String)? {
        
        get {
            
            let username = self.keychain[Authentication.keychainUsernameKey]
            
            let password = self.keychain[Authentication.keychainPasswordKey]
            
            if username == nil || password == nil {
                
                return nil
            }
            
            return (username!, password!)
        }
        
        set {
            
            if self.credentials == nil {
                
                self.keychain[Authentication.keychainUsernameKey] = nil
                
                self.keychain[Authentication.keychainPasswordKey] = nil
                
                return
            }
            
            let (username, password) = self.credentials!
            
            self.keychain[Authentication.keychainUsernameKey] = username
            
            self.keychain[Authentication.keychainPasswordKey] = password
        }
    }
    
    // MARK: - Private Properties
    
    /** The keychain used for storing the credentials. */
    private let keychain: Keychain
    
    // MARK: - Initialization
    
    public init(keychainIdentifier: String = NSBundle.mainBundle().infoDictionary![kCFBundleIdentifierKey] as! String, accessGroup: String? = nil) {
        
        // set keychain
        
        if accessGroup != nil {
            
            self.keychain = Keychain(service: keychainIdentifier, accessGroup: accessGroup!)
        }
        else {
            
            self.keychain = Keychain(service: keychainIdentifier)
        }
    }
    
    
}