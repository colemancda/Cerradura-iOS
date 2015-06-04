//
//  Authentication.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import KeychainAccess

/** Holds the information for authenticating with the server. */
public final class Authentication {
    
    // MARK: - Class Properties
    
    /** Key for storing the password in the keychain. */
    public static let keychainPasswordKey = "Password"
    
    /** Key for storing the username in the keychain. */
    public static let keychainUsernameKey = "Username"
    
    // MARK: - Properties
    
    /** Checks whether the user is logged in on the device. */
    public var isAuthenticated: Bool {
        
        return (self.keychain[Authentication.keychainPasswordKey] != nil) && (self.keychain[Authentication.keychainUsernameKey] != nil)
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