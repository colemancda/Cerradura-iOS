//
//  SharedStore.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import CoreCerraduraClient

// MARK: - Extensions

internal extension Store {
    
    /** Shared store that may be nil. App must ensure that this class property is initialized before use. */
    private(set) static var sharedStore: Store!
    
    /** Creates a Store for use with the Cerradura App. */
    class func loadSharedStore(username: String, password: String, server serverURL: NSURL) {
        
        let prettyPrintJSON: Bool
        
        #if DEBUG
            prettyPrintJSON = true
            #else
            prettyPrintJSON = false
        #endif
        
        self.sharedStore = self.init(managedObjectContextConcurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, serverURL: serverURL, prettyPrintJSON: prettyPrintJSON, username: username, password: password)
        
        // load SQLite
        
        var addPersistentStoreError: NSError?
        
        let persistentStore = self.sharedStore.managedObjectContext.persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: SharedStoreFileURL, options: nil, error: &addPersistentStoreError)
        
        // Log error, try to delete file, and crash
        if persistentStore == nil {
            
            println("Failed to load SQLite file.\n\(addPersistentStoreError)")
            
            self.removeSharedStore()
            
            abort()
        }
    }
    
    class func removeSharedStore() {
        
        // delete file
        
        var deleteError: NSError?
        
        NSFileManager.defaultManager().removeItemAtURL(SharedStoreFileURL, error: &deleteError)
        
        if deleteError != nil {
            
            fatalError("Could not delete old SQLite file.\n\(deleteError)")
        }
        
        println("Deleted old SQLite file")
        
        self.sharedStore = nil
    }
}

// MARK: - Private Constants

internal let SharedStoreFileURL: NSURL = {
    
    let cacheURL = NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
        inDomain: NSSearchPathDomainMask.UserDomainMask,
        appropriateForURL: nil,
        create: false,
        error: nil)!
    
    let fileURL = cacheURL.URLByAppendingPathComponent("data.sqlite")
    
    return fileURL
    }()