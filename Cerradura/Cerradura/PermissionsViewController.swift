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
            
            cell.userInteractionEnabled = false
            
            return
        }
        
        // configure cell...
        
        cell.userInteractionEnabled = true
        
        // permissionCell.permissionLockNameLabel!.text = permission.lock.name
        
        permissionCell.permissionTypeLabel.text = {
            
            return "AnyTime"
            
        }()
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
    
    @IBOutlet weak var permissionLockNameLabel: UILabel!
    
    @IBOutlet weak var permissionTypeLabel: UILabel!
}

