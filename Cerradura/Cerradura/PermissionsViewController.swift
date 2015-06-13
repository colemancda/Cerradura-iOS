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
        let permission = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! Permission
        
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
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let count = super.numberOfSectionsInTableView(tableView)
        
        // hide separators for empty table view
        if count == 0 {
            
            tableView.tableFooterView = UIView()
        }
        else {
            
            tableView.tableFooterView = nil
        }
        
        return count
    }
    
    // MARK: - DZNEmptyDataSetSource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("No Keys", comment: "No Keys")
        
        return NSAttributedString(string: text)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        
        return R.image.keysEmpty
    }
}

// MARK: - Table View Cell

class PermissionCell: UITableViewCell {
    
    @IBOutlet weak var permissionImageView: StyleKitView!
    
    @IBOutlet weak var permissionLockNameLabel: UILabel!
    
    @IBOutlet weak var permissionTypeLabel: UILabel!
}

