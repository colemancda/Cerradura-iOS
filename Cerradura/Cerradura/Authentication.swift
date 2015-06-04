//
//  Authentication.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import KeychainAccess
import CoreCerraduraClient

/** Holds the information for authenticating with the server. */
final class Authentication {
    
    /** Authentication singleton. */
    static let sharedAuthentication = Authentication()
    
    let keychain = Keychain(service: NSBundle.mainBundle().infoDictionary![kCFBundleIdentifierKey] as! String)
    
    /** Checks whether the user is logged in on the device. */
    var isAuthenticated: Bool {
        
        return (self.keychain[AuthenticationPasswordKey] != nil)
    }
    
    
    
    
    
    
    
}

// MARK: - Private Constants

/** Key for storing the password in the keychain. */
private let AuthenticationPasswordKey = "Password"