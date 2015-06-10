//
//  SettingsViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/10/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var changeEmailCell: UITableViewCell!
    
    @IBOutlet weak var changePasswordCell: UITableViewCell!
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    
    // MARK: - Properties
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Methods
    
    // MARK: - Actions
    
    @IBAction func logout(sender: AnyObject) {
        
        // show confirmation dialog
        
        
        
        AuthenticationController.sharedController.logout()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if cell == self.changeEmailCell {
            
            
            return
        }
        
        if cell == self.changePasswordCell {
            
            
            return
        }
        
        if cell == self.logoutCell {
            
            self.logout(self)
            
            return
        }
    }
}