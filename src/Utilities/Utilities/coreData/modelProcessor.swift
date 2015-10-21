//
//  modelProcessor.swift
//  pdf
//
//  Created by Carmelo I. Uria on 10/20/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import Foundation

import CoreData

public class ModelProcessor
{
    public func insert(entries: [String : AnyObject], table: String, managedObjectContext: NSManagedObjectContext) throws
    {
        let managedObject: NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(table, inManagedObjectContext: managedObjectContext)
        
        for (key, value) in entries
        {
            debugPrint("\(__FUNCTION__):  key = \(key): value = \(value)")
            managedObject.setValue(value, forKey: key)
        }
    }

    public func update(entries: [String : AnyObject], entity: NSManagedObject, managedObjectContext: NSManagedObjectContext) throws
    {
        if (entity.fault == true)
        {
            let exception: ModelProcessorException = ModelProcessorException(name: "Fault Exception", reason: "Entity is a fault", userInfo: nil)
            exception.raise()
        }
        
        for (key, value) in entries
        {
            debugPrint("\(__FUNCTION__):  key = \(key): value = \(value)")
        }
    }

    public func delete(entity: NSManagedObject, managedObjectContext: NSManagedObjectContext) throws
    {
        if (entity.fault == true)
        {
            let exception: ModelProcessorException = ModelProcessorException(name: "Fault Exception", reason: "Entity is a fault", userInfo: nil)
            exception.raise()
        }
        
        managedObjectContext.deleteObject(entity)
    }

    public func test() throws
    {
        let exception: ModelProcessorException = ModelProcessorException()
        exception.raise()        
    }
}
