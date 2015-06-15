//
//  PermissionsViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/10/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreCerradura
import CoreCerraduraClient
import DZNEmptyDataSet
import NetworkObjectsUI

class PermissionsViewController: ArchivableFetchedResultsViewController, DZNEmptyDataSetSource {
        
    // MARK: - Initialization
    
    deinit {
        
        self.tableView.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.store = Store.sharedStore
        
        self.tableView.emptyDataSetSource = self
        
        self.tableView.reloadData()
        
        self.localSortDescriptors = [NSSortDescriptor(key: "lock.name", ascending: true)]
        
        self.fetchRequest = {
            
            let fetchRequest = NSFetchRequest(entityName: "Permission")
            
            fetchRequest.predicate = NSPredicate(format: "archived == NO && user == %@", argumentArray: [AuthenticationController.sharedController.authenticatedUser!])
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            
            return fetchRequest
        }()
        
        
    }
    
    // MARK: - Methods
    
    override func dequeueReusableCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        
        return self.tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.permissionCell, forIndexPath: indexPath)!
    }
    
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withError error: NSError?) {
        
        if error != nil {
            
            // TODO: Configure cell for error
            
        }
        
        let permissionCell = cell as! PermissionCell
        
        // get model object
        let permission = self.objectAtIndexPath(indexPath) as! Permission
        
        let dateCached = permission.valueForKey(Store.sharedStore.dateCachedAttributeName!) as? NSDate
        
        // not cached
        
        if dateCached == nil {
            
            // configure empty cell...
            
            permissionCell.permissionLockNameLabel!.text = NSLocalizedString("Loading...", comment: "Loading...")
            
            permissionCell.activityIndicatorView.hidden = false
            
            permissionCell.permissionImageView.hidden = true
            
            permissionCell.activityIndicatorView.startAnimating()
            
            permissionCell.permissionTypeLabel.text = ""
            
            cell.userInteractionEnabled = false
            
            return
        }
        
        // permission cached
        
        // configure cell...
        
        cell.userInteractionEnabled = true
        
        permissionCell.permissionTypeLabel.text = {
            
            switch PermissionType(rawValue: permission.permissionType)! {
                
            case .Admin: return NSLocalizedString("Admin", comment: "Admin Permission Text")
            case .Anytime: return NSLocalizedString("Anytime", comment: "Anytime Permission Text")
            case .Scheduled: return NSLocalizedString("Scheduled", comment: "Scheduled Permission Text")
            }
        }()
        
        permissionCell.permissionImageView.hidden = false
        
        permissionCell.activityIndicatorView.stopAnimating()
        
        permissionCell.permissionImageView.canvasName = {
            
            switch PermissionType(rawValue: permission.permissionType)! {
                
            case .Admin: return StyleKitCanvas.PermissionBadgeAdmin.rawValue
            case .Anytime: return StyleKitCanvas.PermissionBadgeAnytime.rawValue
            case .Scheduled: return StyleKitCanvas.PermissionBadgeScheduled.rawValue
            }
        }()
        
        // load lock info
        
        let lockDateCached = permission.lock.valueForKey(Store.sharedStore.dateCachedAttributeName!) as? NSDate
        
        if lockDateCached == nil {
            
            permissionCell.permissionLockNameLabel!.text = NSLocalizedString("Loading...", comment: "Loading...")
            
            self.store.fetchResource(permission.lock, completionBlock: {[weak self] (error: NSError?) -> Void in
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    if self == nil {
                        
                        return
                    }
                    
                    // out of bounds
                    if indexPath.row > (self!.tableView.numberOfRowsInSection(0) - 1) {
                        
                        return
                    }
                    
                    let currentPermissionForCell = self!.objectAtIndexPath(indexPath)
                    
                    if currentPermissionForCell != permission {
                        
                        return
                    }
                    
                    if error != nil {
                        
                        permissionCell.permissionLockNameLabel.text = NSLocalizedString("Error", comment: "Error")
                        
                        return
                    }
                    
                    permissionCell.permissionLockNameLabel!.text = permission.lock.name
                    
                })
            })
        }
        else {
            
            permissionCell.permissionLockNameLabel!.text = permission.lock.name
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // show detail controller
        
        let permissionNavigationStack = R.storyboard.permission.initialViewController!
        
        self.showAdaptiveDetailController(permissionNavigationStack)
        
        // set permission
        
        let permission = self.objectAtIndexPath(indexPath) as! Permission
        
        let permissionVC = permissionNavigationStack.topViewController as! PermissionViewController
        
        permissionVC.permission = permission
    }
}

// MARK: - Table View Cell

class PermissionCell: UITableViewCell {
    
    @IBOutlet weak var permissionImageView: StyleKitView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var permissionLockNameLabel: UILabel!
    
    @IBOutlet weak var permissionTypeLabel: UILabel!
}

