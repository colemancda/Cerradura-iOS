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

class PermissionsViewController: FetchedResultsViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    // MARK: - IB Outlets
    
    
    
    // MARK: - Initialization
    
    deinit {
        
        self.tableView.emptyDataSetDelegate = nil
        self.tableView.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.reloadData()
        
        /*
        self.fetchRequest = {
            
            let fetchRequest = NSFetchRequest(entityName: "Permission")
            
            fetchRequest.predicate = NSPredicate(format: "archived == NO && user == %@", argumentArray: [])
            
            return fetchRequest
        }()
        */
        
    }
    
    // MARK: - Methods
    
    // MARK: - DZNEmptyDataSetSource
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("No Keys", comment: "No Keys")
        
        return NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName: StyleKit.placeholderGrey])
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        
        return R.image.keysEmptyData
    }
    
    // MARK: - DZNEmptyDataSetDelegate
    
    
}