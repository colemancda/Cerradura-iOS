//
//  LocalLockViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/13/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

/** Searches for locks via Bluetooth and shows details when in range. */
class LocalLockViewController: UIViewController {
    
    // MARK: - Properties
    
    var mode: LocalLockViewControllerMode!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // start searching mode
        self.mode = .Searching
    }
    
    
}

// MARK: - Enumerations

enum LocalLockViewControllerMode {
    
    /** Searching for local locks. */
    case Searching
    
    /** Found a local lock. Will proceed to display the lock. */
    case Found
    
    /** Displayed the found lock. */
    case Shown
}