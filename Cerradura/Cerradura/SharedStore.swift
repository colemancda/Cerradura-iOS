//
//  SharedStore.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/4/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreCerraduraClient

extension Store {
    
    /** Shared store that may be nil. App must ensure that this class property is initialized before use. */
    static var sharedStore: Store!
}