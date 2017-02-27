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
    
    func fetchSearchHistory() -> [CD_SearchHistoryItem]?
    {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("CD_SearchHistoryItem", inManagedObjectContext: appDelegate.managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        do {
            let results = try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            return results as? [CD_SearchHistoryItem]
        } catch {
            let fetchError = error as NSError
            print("error = \(fetchError)")
        }
        return nil
    }
    
    func saveSearchHistoryItem(searchTerm: String, timeStamp: NSTimeInterval) -> CD_SearchHistoryItem
    {
        let entity = NSEntityDescription.entityForName("CD_SearchHistoryItem", inManagedObjectContext: appDelegate.managedObjectContext)!
        let searchHistoryItem = CD_SearchHistoryItem(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        searchHistoryItem.searchTerm = searchTerm
        searchHistoryItem.timeStamp = timeStamp
        do {
            try searchHistoryItem.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("error = \(saveError)")
        }
        return searchHistoryItem
    }
    
    func deleteSearchHistoryItem(searchHistoryItem: CD_SearchHistoryItem)
    {
        appDelegate.managedObjectContext.deleteObject(searchHistoryItem)
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("error = \(saveError)")
        }
    }
}
