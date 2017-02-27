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
    static var sharedInstance = CoreDataController()
    
    func fetchSearchHistory() -> [String]
    {
        var history = [String]()
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("CD_SearchTerm", inManagedObjectContext: appDelegate.managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        do {
            let result = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            if let searchTerms = result as? [CD_SearchTerm]
            {
                for searchTerm in searchTerms
                {
                    history.append(searchTerm.term!)
                }
            }
        } catch {
            let fetchError = error as NSError
            print("error = \(fetchError)")
            // TODO handler error
        }
        return history
    }
    
    func saveSearchTerm(term: String, timeStamp: NSTimeInterval)
    {
        if let entity = NSEntityDescription.entityForName("CD_SearchTerm", inManagedObjectContext: appDelegate.managedObjectContext)
        {
            let searchTerm = CD_SearchTerm(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
            searchTerm.term = term
            searchTerm.timeStamp = timeStamp
            do {
                try searchTerm.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print("error = \(saveError)")
                // TODO handler error
            }
        }
    }
    
}
