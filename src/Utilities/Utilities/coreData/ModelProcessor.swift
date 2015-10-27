//
//  ModelProcessor.swift
//  Utilities
//
//  Created by Carmelo I. Uria on 10/20/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import Foundation

import CoreData

enum ModelProcessorError: ErrorType {
    case Bad
    case Worse
    case DeleteError
}

public class ModelProcessor
{

    public init()
    {
        
    }
    
    public func retrieve(table: String, managedObjectContext: NSManagedObjectContext) throws -> [AnyObject]
    {
        let fetchRequest: NSFetchRequest = NSFetchRequest(entityName: table)
        
        var entities: [AnyObject] = []
        
        entities = try managedObjectContext.executeFetchRequest(fetchRequest)
       
        return entities
    }
    
    public func insert(entries: [String : AnyObject], table: String, managedObjectContext: NSManagedObjectContext)
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
            throw ModelProcessorError.DeleteError
        }
        
        managedObjectContext.deleteObject(entity)
    }

}
