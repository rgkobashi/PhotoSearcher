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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entity = NSEntityDescription.entity(forEntityName: "CD_SearchHistoryItem", in: appDelegate.managedObjectContext)
        fetchRequest.entity = entity
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        do {
            let results = try appDelegate.managedObjectContext.fetch(fetchRequest)
            return results as? [CD_SearchHistoryItem]
        } catch {
            let fetchError = error as NSError
            print("error = \(fetchError)")
        }
        return nil
    }
    
    func saveSearchHistoryItemWithSearchTerm(_ searchTerm: String, timeStamp: TimeInterval) -> CD_SearchHistoryItem
    {
        let entity = NSEntityDescription.entity(forEntityName: "CD_SearchHistoryItem", in: appDelegate.managedObjectContext)!
        let searchHistoryItem = CD_SearchHistoryItem(entity: entity, insertInto: appDelegate.managedObjectContext)
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
    
    func deleteSearchHistoryItem(_ searchHistoryItem: CD_SearchHistoryItem)
    {
        appDelegate.managedObjectContext.delete(searchHistoryItem)
        do {
            try appDelegate.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("error = \(saveError)")
        }
    }
}
