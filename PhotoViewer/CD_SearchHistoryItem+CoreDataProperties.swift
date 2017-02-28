//
//  CD_SearchHistoryItem+CoreDataProperties.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CD_SearchHistoryItem {

    @NSManaged var searchTerm: String?
    @NSManaged var timeStamp: TimeInterval

}
