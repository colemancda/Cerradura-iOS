//
//  MainStoryboard.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/10/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

extension ManagedObjectViewController {
    
    func handleManagedObjectDeletionForViewControllerInMainStoryboard() {
        
        // Detect if contained in splitViewController
        let regularLayout: Bool = (self.splitViewController?.viewControllers.count == 2) ?? false
        
        // Regular layout
        if regularLayout {
            
            // show empty selection if root VC and visible detail VC
            if self.navigationController!.viewControllers.first! as! UIViewController == self &&
                self.splitViewController!.viewControllers[1] as! UIViewController == self.navigationController! {
                    
                    // get detail navigation controller stack
                    let detailNavigationController = self.storyboard!.instantiateViewControllerWithIdentifier("EmptySelection") as! UINavigationController
                    
                    // set detailVC
                    self.splitViewController!.showDetailViewController(detailNavigationController, sender: self)
            }
        }
            
            // Compact layout
        else {
            
            // pop to root VC if top if second VC
            if self.navigationController!.viewControllers[1] as? UIViewController == self {
                
                self.navigationController!.popToRootViewControllerAnimated(true)
            }
        }
    }
}