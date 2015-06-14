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
    
    // MARK: - IB Outlets
    
    
    
    // MARK: - Properties
    
    /** The permission that this view controller will display. */
    var permission: Permission! {
        
        didSet {
            
            self.permissionManagedObjectController = ManagedObjectController(managedObject: self.permission, store: Store.sharedStore)
            
            self.configurePermissionManagedObjectController()
        }
    }
    
    // MARK: - Private Properties
    
    private var permissionManagedObjectController: ManagedObjectController!
    
    private var lockManagedObjectController: ManagedObjectController?
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.configureLoadingUI()
    }
    
    // MARK: - Transition
    
    override func viewWillAppear(animated: Bool) {
        
        // reload
    }
    
    // MARK: - Actions
    
    @IBAction func unlock(sender: AnyObject) {
        
        
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        weak var weakSelf = self
        
        Store.sharedStore.fetchEntity("Permission", resourceID: self.permission.valueForKey("id") as! UInt, completionBlock: { (error: NSError?, managedObject: NSManagedObject?) -> Void in
            
            if weakSelf == nil {
                
                return
            }
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                if error != nil {
                    
                    weakSelf!.showErrorAlert(error!.localizedDescription, retryHandler: {
                        
                        weakSelf!.refresh(weakSelf!)
                    })
        
                    return
                }
                
                
                
            })
            
        })
    }
    
    // MARK: - Private Methods
    
    private func configurePermissionManagedObjectController() {
        
        self.permissionManagedObjectController.deletionHandler = {
            
            self.handleManagedObjectDeletionInMainStoryboard()
        }
        
        self.permissionManagedObjectController.observeProperty("archived", changeHandler: { (change: ManagedObjectPropertyValueChange<Bool>) -> Void in
            
            if change.value == true {
                
                self.handleManagedObjectDeletionInMainStoryboard()
            }
        })
        
        self.permissionManagedObjectController.observeProperty("lock", changeHandler: { (change: ManagedObjectPropertyValueChange<Lock>) -> Void in
            
            if let lock = change.value {
                
                self.lockManagedObjectController = ManagedObjectController(managedObject: self.permission.lock, store: Store.sharedStore)
            }
            
            
            
        })
    }
    
    private func configureLockManagedObjectController() {
        
        self.lockManagedObjectController!.observeProperty("name", changeHandler: { (change: ManagedObjectPropertyValueChange<String>) -> Void in
            
            if let name = change.value {
                
                self.navigationItem.title = name
            }
        })
    }
    
    private func configureLoadingUI() {
        
        
    }
}