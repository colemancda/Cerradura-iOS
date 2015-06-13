//
//  Appearance.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/9/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

internal func ConfigureAppearance() {
    
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
    UINavigationBar.appearance().barTintColor = StyleKit.cerraduraBlue
    
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
    UITabBar.appearance().tintColor = StyleKit.cerraduraBlue
    
    UIButton.appearance().tintColor = StyleKit.cerraduraBlue
    
}