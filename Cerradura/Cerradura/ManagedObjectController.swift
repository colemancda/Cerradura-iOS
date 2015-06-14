//
//  ManagedObjectController.swift
//  NetworkObjects
//
//  Created by Alsey Coleman Miller on 6/13/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData
import NetworkObjects

/** Observes and controls a managed object. */
final public class ManagedObjectController: NSObject {
    
    // MARK: - Properties
    
    public let managedObject: NSManagedObject
    
    public let store: Store
    
    public var deletionHandler: (() -> Void)? {
        
        didSet {
            
            // register for notifications
            
            if deletionHandler != nil {
                
                self.managedObject.addObserver(self, forKeyPath: ManagedObjectKey.Deleted.rawValue, options: .Initial | .New, context: self.KVOContext)
            }
            else {
                
                self.managedObject.removeObserver(self, forKeyPath: ManagedObjectKey.Deleted.rawValue, context: self.KVOContext)
            }
        }
    }
    
    /** Handler called when managedObject is cached from server. Do not set if your Store's dateCachedAttributeName is set to nil. */
    public var cachedHandler: ((firstCache: Bool) -> Void)? {
        
        didSet {
            
            assert(store.dateCachedAttributeName != nil, "dateCachedAttributeName must not be nil")
            
            if cachedHandler != nil {
                
                self.managedObject.addObserver(self, forKeyPath: self.store.dateCachedAttributeName!, options: .Initial | .New, context: self.KVOContext)
            }
            else {
                
                self.managedObject.removeObserver(self, forKeyPath: self.store.dateCachedAttributeName!, context: self.KVOContext)
            }
        
        }
    }
    
    // MARK: - Private Properties
    
    private let KVOContext = UnsafeMutablePointer<Void>()
    
    private var observedProperties = [String: ChangeHandler]()
    
    private var cached: Bool = false
    
    // MARK: - Initialization
    
    deinit {
        
        // stop observing all properties
        
        for (property, handler) in self.observedProperties {
            
            self.stopObservingProperty(property)
        }
        
        self.deletionHandler = nil
        self.cachedHandler = nil
    }
    
    public init(managedObject: NSManagedObject, store: Store) {
        
        self.managedObject = managedObject
        self.store = store
        
        if let dateCachedAttributeName = self.store.dateCachedAttributeName {
        
            self.cached = (managedObject.valueForKey(self.store.dateCachedAttributeName!) != nil)
        }
    }
    
    // MARK: - Methods
    
    public func observeProperty<ValueType: Any>(propertyName: String, changeHandler: (change: ManagedObjectPropertyValueChange<ValueType>) -> Void) {
        
        // register for notifications
        
        self.managedObject.addObserver(self, forKeyPath: propertyName, options: .Initial | .New | .Old, context: self.KVOContext)
        
        // set handler
        self.observedProperties[propertyName] = {(oldValue: Any?, newValue: Any?) -> Void in
            
            let change = ManagedObjectPropertyValueChange<ValueType>(oldValue: oldValue as? ValueType, value: newValue as? ValueType)
            
            changeHandler(change: change)
        }
    }
    
    public func stopObservingProperty(propertyName: String) {
        
        self.managedObject.removeObserver(self, forKeyPath: propertyName, context: self.KVOContext)
        
        self.observedProperties[propertyName] = nil
    }
    
    // MARK: - KVO
    
    @objc public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context == self.KVOContext {
            
            // managed Object changes
            if object as? NSManagedObject == self.managedObject {
                
                if keyPath == ManagedObjectKey.Deleted.rawValue {
                    
                    if self.managedObject.deleted {
                        
                        self.deletionHandler?()
                    }
                    
                    return
                }
                
                if keyPath == self.store.dateCachedAttributeName {
                    
                    if self.managedObject.valueForKey(self.store.dateCachedAttributeName!) != nil {
                        
                        self.cachedHandler?(firstCache: !self.cached)
                        
                        // set cached value
                        if self.cached == false {
                            
                            self.cached = true
                        }
                    }
                    
                    return
                }
                
                // check for registered key paths
                
                for (property, handler) in self.observedProperties {
                    
                    if property == keyPath {
                        
                        handler(oldValue: change[NSKeyValueChangeOldKey], newValue: object.valueForKey(keyPath))
                    
                        return
                    }
                }
            }
        }
    }
}

// MARK: - Structures

public struct ManagedObjectPropertyValueChange<T> {
    
    let oldValue: T?
    
    let value: T?
}

// MARK: - Private Types

private typealias ChangeHandler = (oldValue: Any?, newValue: Any?) -> Void

private enum ManagedObjectKey: String {
    
    case Deleted = "deleted"
    
    static let keys: [ManagedObjectKey] = [.Deleted]
}



