//
//  CoreDataController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController
{
    // TODO consider rename SearchTerm and CD_SearchTerm and its properties
    
    static var sharedInstance = CoreDataController()
    
    func fetchSearchHistory() -> [CD_SearchTerm]?
    {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("CD_SearchTerm", inManagedObjectContext: appDelegate.managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        do {
            let results = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            return results as? [CD_SearchTerm]
        } catch {
            let fetchError = error as NSError
            print("error = \(fetchError)")
            // TODO handler error
        }
        return nil
    }
    
    func saveSearchTerm(term: String, timeStamp: NSTimeInterval) -> CD_SearchTerm?
    {
        if let entity = NSEntityDescription.entityForName("CD_SearchTerm", inManagedObjectContext: appDelegate.managedObjectContext)
        {
            let searchTerm = CD_SearchTerm(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
            searchTerm.term = term
            searchTerm.timeStamp = timeStamp
            do {
                try searchTerm.managedObjectContext?.save()
                return searchTerm
            } catch {
                let saveError = error as NSError
                print("error = \(saveError)")
                // TODO handler error
            }
        }
        return nil
    }
    
    func deleteSearchTerm(searchTerm: CD_SearchTerm)
    {
        appDelegate.managedObjectContext.deleteObject(searchTerm)
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("error = \(saveError)")
            // TODO handler error
        }
    }
}
