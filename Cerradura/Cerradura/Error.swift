//
//  Error.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/5/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation

/** The reverse DNS error domain string for Cerradura. */
public let CerraduraErrorDomain = "com.ColemanCDA.Cerradura.ErrorDomain"

/** Error codes used with Cerradura. */
public enum ErrorCode: Int {
    
    /** Could not fetch the user ID after a login. Server inconsistency. */
    case CouldNotFetchUserID
}

public extension ErrorCode {
    
    /** Returns generic errors for error codes. */
    func toError() -> NSError {
        
        let frameworkBundle = NSBundle(identifier: "com.ColemanCDA.Cerradura")
        
        let tableName = "Error"
        
        let comment = "NSLocalizedDescriptionKey for NSError with ErrorCode.\(self.rawValue)"
        
        let key = "ErrorCode.\(self.rawValue).LocalizedDescription"
        
        var value: String?
        
        switch self {
        case .CouldNotFetchUserID:
            value = "Could not fetch the user ID. Server inconsistency."
            
        default:
            value = "Error"
        }
        
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString(key, tableName: tableName, bundle: frameworkBundle!, value: value!, comment: comment)]
        
        return NSError(domain: CerraduraErrorDomain, code: self.rawValue, userInfo: userInfo)
    }
}