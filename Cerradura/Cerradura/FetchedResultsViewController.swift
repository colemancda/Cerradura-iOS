//
//  FetchedResultsViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 12/10/14.
//  Copyright (c) 2014 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import NetworkObjects
import ExSwift

/** Fetches instances of an entity on the server and displays them in a table view. Supports single section only. */
public class FetchedResultsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    /** NetworkObjects Store that this view controller will use. Make sure to set this value before loading this class. */
    public var store: Store!
    
    /** The fetch request that will be converted into a search request. Also used to created a fetched results controller to display content. */
    public var fetchRequest: NSFetchRequest? {
        
        didSet {
            
            if fetchRequest == nil {
                
                self.fetchedResultsController = nil
                
                return
            }
            
            let searchRequest = fetchRequest!.copy() as! NSFetchRequest
            
            assert(searchRequest.sortDescriptors != nil, "The fetched request for the seach operation must specify sort descriptors")
            
            // add additional sort descriptors
            if let additionalSortDescriptors = self.localSortDescriptors {
                
                var sortDescriptors = additionalSortDescriptors
                
                sortDescriptors += searchRequest.sortDescriptors as! [NSSortDescriptor]
                
                searchRequest.sortDescriptors = sortDescriptors
            }
            
            // create new fetched results controller
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: searchRequest, managedObjectContext: self.store.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            
            fetchedResultsController.delegate = self
            
            self.fetchedResultsController = fetchedResultsController
            
            // perform fetch if view is loaded
            if self.isViewLoaded() {
                
                var error: NSError?
                
                self.fetchedResultsController?.performFetch(&error)
                
                assert(error == nil, "Could not execute -performFetch: on NSFetchedResultsController. (\(error!.localizedDescription))")
                
                // load from server
                self.refresh(self)
            }
        }
    }
    
    /** Sort descriptors that are additionally applied to the search results. Not sent with requests. Must set before setting fetch request. */
    public var localSortDescriptors: [NSSortDescriptor]?
    
    /** Date the data was last pulled from the server. */
    public private(set) var datedRefreshed: NSDate?
    
    /** Managed objects fetched from the server. Do not modify. */
    public private(set) var searchResults = [NSManagedObject]()
    
    public private(set) var fetchedResultsController: NSFetchedResultsController?
    
    // MARK: - Initialization
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var error: NSError?
        
        self.fetchedResultsController?.performFetch(&error)
        
        assert(error == nil, "Could not execute -performFetch: on NSFetchedResultsController. (\(error!.localizedDescription))")
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // start reloading data before view appears
        self.refresh(self)
    }
    
    // MARK: - Methods
    
    /** Subclasses should overrride this to provide custom cells. */
    public func dequeueReusableCellForIndexPath(indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = NSStringFromClass(UITableViewCell)
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as? UITableViewCell
        
        if cell == nil {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
        }
        
        return cell!
    }
    
    /** Subclasses should override this to configure custom cells. */
    public func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath, withError error: NSError? = nil) {
        
        if error != nil {
            
            // TODO: Configure cell for error
            
            return
        }
        
        // get model object
        let managedObject = self.searchResults[indexPath.row]
        
        let dateCached = managedObject.valueForKey(self.store.dateCachedAttributeName!) as? NSDate
        
        // not cached
        
        if dateCached == nil {
            
            // configure empty cell...
            
            cell.textLabel?.text = NSLocalizedString("Loading...", comment: "Loading...")
            
            cell.detailTextLabel?.text = ""
            
            cell.userInteractionEnabled = false
            
            return
        }
        
        // configure cell...
        
        cell.userInteractionEnabled = true
        
        // Entity name + resource ID
        cell.textLabel!.text = "\(managedObject.entity)" + "\(managedObject.valueForKey(self.store.resourceIDAttributeName))"
    }
    
    // MARK: - Actions
    
    @IBAction public func refresh(sender: AnyObject) {
        
        if self.fetchRequest == nil {
            
            self.refreshControl?.endRefreshing()
            
            return
        }
        
        self.datedRefreshed = NSDate()
        
        self.store.performSearch(self.fetchRequest!, completionBlock: { (error: NSError?, results: [NSManagedObject]?) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                self.refreshControl?.endRefreshing()
                
                // show error
                if error != nil {
                    
                    self.showErrorAlert(error!.localizedDescription, retryHandler: { () -> Void in
                        
                        self.refresh(self)
                    })
                    
                    return
                }
                
                let sortedResults: [NSManagedObject]
                
                if let additionalSortDescriptors = self.localSortDescriptors {
                    
                    var sortDescriptors = additionalSortDescriptors
                    
                    sortDescriptors += self.fetchedResultsController!.fetchRequest.sortDescriptors as! [NSSortDescriptor]
                    
                    sortedResults = (results! as NSArray).sortedArrayUsingDescriptors(sortDescriptors) as! [NSManagedObject]
                }
                
                else {
                    
                    sortedResults = results!
                }
                
                self.searchResults = sortedResults
                
                self.tableView.reloadData()
            })
        })
    }
    
    // MARK: - Private Methods
    
    private func deleteManagedObject(managedObject: NSManagedObject) {
        
        self.store.deleteManagedObject(managedObject, completionBlock: { (error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                // show error
                if error != nil {
                    
                    self.showErrorAlert(error!.localizedDescription, retryHandler: { () -> Void in
                        
                        self.deleteManagedObject(managedObject)
                    })
                    
                    return
                }
                
            })
        })
    }
    
    // MARK: - UITableViewDataSource
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.dequeueReusableCellForIndexPath(indexPath) as UITableViewCell
        
        // configure cell
        self.configureCell(cell, atIndexPath: indexPath)
        
        // fetch from server... (loading table view after -refresh:)
        
        if self.datedRefreshed != nil {
            
            // get model object
            let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! NSManagedObject
            
            // get date cached
            let dateCached = managedObject.valueForKey(self.store.dateCachedAttributeName!) as? NSDate
            
            // fetch if older than refresh date or not fetched yet
            if dateCached == nil || dateCached?.compare(self.datedRefreshed!) == NSComparisonResult.OrderedAscending {
                
                self.store.fetchEntity(managedObject.entity.name!, resourceID: managedObject.valueForKey(self.store.resourceIDAttributeName) as! UInt, completionBlock: { (error, managedObject) -> Void in
                    
                    // configure error cell
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        
                        if error != nil {
                            
                            // get cell for error request (may have changed)
                            
                            // TODO: handle error (show error text in cell)
                        }
                    })
                    
                    // fetched results controller should update cell
                })
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    public override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // get model object
        let managedObject = self.fetchedResultsController!.objectAtIndexPath(indexPath) as! NSManagedObject
        
        switch editingStyle {
            
        case .Delete:
            
            self.deleteManagedObject(managedObject)
            
        default:
            
            return
        }
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    public func controller(controller: NSFetchedResultsController,
        didChangeObject object: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Update:
                if let cell = self.tableView.cellForRowAtIndexPath(indexPath!) {
                    
                    self.configureCell(cell, atIndexPath: indexPath!)
                }
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
            default:
                return
            }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
}
