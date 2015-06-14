//
//  ManagedObjectController.swift
//  NetworkObjects
//
//  Created by Alsey Coleman Miller on 6/13/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import CoreData

/** Observes and controls a managed object. */
final public class ManagedObjectController<ManagedObjectClass: NSManagedObject>: NSObject {
    
    // MARK: - Properties
    
    public let managedObject: ManagedObjectClass
    
    public var deletionHandler: (() -> Void)? {
        
        didSet {
            
            
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
        
        self.deletionHandler = nil
    }
    
    public init(managedObject: ManagedObjectClass) {
        
        self.managedObject = managedObject
        self.store = store
    }
    
    // MARK: - Methods
    
    public func observeProperty<ValueType: Any>(propertyName: String, changeHandler: (change: ManagedObjectPropertyValueChange<ValueType>) -> Void) {
        
        // register for notifications
        
        self.managedObject.addObserver(self, forKeyPath: propertyName, options: NSKeyValueObservingOptions.Initial, context: self.KVOContext)
        
        // set handler
        self.observedProperties[propertyName] = ((oldValue: Any?, newValue: Any?) -> Void in
            
            let change = ManagedObjectPropertyValueChange<ValueType>(oldValue: oldValue as? ValueType, newValue: newValue as? ValueType)
            
            changeHandler(change: change)
        )
    }
    
    public func stopObservingProperty(propertyName: String) {
        
        self.observedProperties[propertyName] = nil
    }
    
    // MARK: - Notifications
    
    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        
        if self.managedObject == nil {
            
            return
        }
        
        if let deletedObjects = notification.userInfo![NSDeletedObjectsKey] as? NSSet {
            
            if deletedObjects.containsObject(self.managedObject!) {
                
                self.managedObjectWasDeleted()
            }
        }
    }
}

// MARK: - Structures

public struct ManagedObjectPropertyValueChange<T> {
    
    let oldValue: T?
    
    let newValue: T?
}

// MARK: - Private Types

private typealias ChangeHandler = (oldValue: Any?, NewValue: Any?) -> Void



