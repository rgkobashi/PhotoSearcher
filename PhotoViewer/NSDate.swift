//
//  NSDate.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

extension NSDate
{
    func stringUTC() -> String?
    {
        let formatter = NSDateFormatter()
        let timeZone = NSTimeZone(name: "UTC")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.stringFromDate(self)
    }
}
