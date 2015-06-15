//
//  ArchivableFetchedResultsViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/12/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import NetworkObjects
import NetworkObjectsUI
import CoreCerradura

/** Subclass of FetchedResultsViewController that archives objects instead of deleting them. */
class ArchivableFetchedResultsViewController: FetchedResultsViewController {
    
    // MARK: - Private Methods
    
    private func archiveManagedObject(managedObject: NSManagedObject) {
        
        self.store.performFunction(function: ArchiveFunctionName, forManagedObject: managedObject, withJSONObject: nil) { (error, functionCode, JSONResponse) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                // show error
                if error != nil {
                    
                    self.showErrorAlert(error!.localizedDescription, retryHandler: { () -> Void in
                        
                        self.archiveManagedObject(managedObject)
                    })
                    
                    return
                }
                
            })
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let managedObject = self.objectAtIndexPath(indexPath)
        
        switch editingStyle {
            
        case .Delete:
            
            self.archiveManagedObject(managedObject)
            
        default:
            
            return
        }
    }
}