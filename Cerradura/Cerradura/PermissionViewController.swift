//
//  PermissionViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/13/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreCerraduraClient
import CoreCerradura

class PermissionViewController: UIViewController {
    
    // MARK: - Properties
    
    /** The permission that this view controller will display. */
    var permission: Permission! {
        
        didSet {
            
            self.managedObjectController = ManagedObjectController<Permission>(managedObject: self.permission, store: Store.sharedStore)
            
            self.configureManagedObjectController()
        }
    }
    
    // MARK: - Private Properties
    
    var managedObjectController: ManagedObjectController<Permission>!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func unlock(sender: UIButton) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func configureManagedObjectController() {
        
        self.managedObjectController.deletionHandler = {
            
            self.handleManagedObjectDeletionInMainStoryboard()
        }
        
        self.managedObjectController.observeProperty("archived", changeHandler: { (change: ManagedObjectPropertyValueChange<Bool>) -> Void in
            
            if change.newValue == true {
                
                self.handleManagedObjectDeletionInMainStoryboard()
            }
        })
        
    }
    
}