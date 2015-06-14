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
final public class ManagedObjectController<T: NSManagedObject>: NSObject {
    
    // MARK: - Properties
    
    public let managedObject: T
    
    public let store: Store
    
    public weak var delegate: ManagedObjectControllerDelegate<T>? {
    
        didSet {
            
            // register for notifications
            
            if delegate != nil {
                
                self.managedObject.addObserver(self, forKeyPath: ManagedObjectKey.Deleted.rawValue, options: .Initial | .New, context: self.KVOContext)
                
                if self.store.dateCachedAttributeName != nil {
                    
                    self.managedObject.addObserver(self, forKeyPath: self.store.dateCachedAttributeName!, options: .Initial | .New, context: self.KVOContext)
                }
            }
            else {
                
                self.managedObject.removeObserver(self, forKeyPath: ManagedObjectKey.Deleted.rawValue, context: self.KVOContext)
                
                if self.store.dateCachedAttributeName != nil {
                    
                    self.managedObject.removeObserver(self, forKeyPath: self.store.dateCachedAttributeName!, context: self.KVOContext)
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let KVOContext = UnsafeMutablePointer<Void>()
    
    private var observedProperties = [String: ChangeHandler]()
    
    // MARK: - Initialization
    
    deinit {
        
        // stop observing all properties
        
        for (property, handler) in self.observedProperties {
            
            self.stopObservingProperty(property)
        }
        
        self.delegate = nil
    }
    
    public init(managedObject: T, store: Store) {
        
        self.managedObject = managedObject
        self.store = store
    }
    
    // MARK: - Methods
    
    public func observeProperty<ValueType: Any>(propertyName: String, changeHandler: (change: ManagedObjectPropertyValueChange<ValueType>) -> Void) {
        
        // register for notifications
        
        self.managedObject.addObserver(self, forKeyPath: propertyName, options: .Initial | .New | .Old, context: self.KVOContext)
        
        // set handler
        self.observedProperties[propertyName] = {(oldValue: Any?, newValue: Any?) -> Void in
            
            let change = ManagedObjectPropertyValueChange<ValueType>(oldValue: oldValue as? ValueType, newValue: newValue as? ValueType)
            
            changeHandler(change: change)
        }
    }
    
    public func stopObservingProperty(propertyName: String) {
        
        self.removeObserver(self, forKeyPath: propertyName, context: self.KVOContext)
        
        self.observedProperties[propertyName] = nil
    }
    
    // MARK: - KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if context != self.KVOContext {
            
            // managed Object changes
            if object as? NSManagedObject == self.managedObject {
                
                if keyPath == ManagedObjectKey.Deleted.rawValue {
                    
                    if self.managedObject.deleted {
                        
                        self.delegate?.managedObjectController(self, managedObjectWasDeleted: self.managedObject)
                    }
                    
                    return
                }
                
                if keyPath == self.store.dateCachedAttributeName {
                    
                    
                }
                
                // check for registered key paths
                
                for (property, handler) in self.observedProperties {
                    
                    if property == keyPath {
                        
                        handler(oldValue: change[NSKeyValueChangeOldKey], NewValue: change[NSKeyValueChangeNewKey])
                    
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
    
    let newValue: T?
}

// MARK: - Protocol

public protocol ManagedObjectControllerDelegate: class {
    
    typealias ManagedObjectClass: NSManagedObject
    
    func managedObjectController(controller: ManagedObjectController<ManagedObjectClass>, managedObjectWasDeleted: NSManagedObject)
    
    func managedObjectController(controller: ManagedObjectController<ManagedObjectClass>, managedObjectWasCached cacheDate: NSDate)
}

// MARK: - Private Types

private typealias ChangeHandler = (oldValue: Any?, NewValue: Any?) -> Void

private enum ManagedObjectKey: String {
    
    case Deleted = "deleted"
    
    static let keys: [ManagedObjectKey] = [.Deleted]
}



