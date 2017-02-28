//
//  Components.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

typealias VoidCompletionHandler = () -> ()
typealias SuceedCompletionHandler = (AnyObject?) -> ()
typealias ErrorCompletionHandler = (NSError) -> ()

class Components
{
    class func downloadImageFrom(urlString: String, suceedHandler: SuceedCompletionHandler, failedHandler: ErrorCompletionHandler)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) { () -> Void in
            let url = NSURL(string: urlString)
            if let url = url
            {
                let data = NSData(contentsOfURL: url)
                if let data = data
                {
                    let image = UIImage(data: data)
                    if let image = image
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            suceedHandler(image)
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Image could not be initialized from the specified data."])
                            failedHandler(error)
                        })
                    }
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from the server."])
                        failedHandler(error)
                    })
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL string malformed."])
                    failedHandler(error)
                })
            }
        }
    }
    
    class func displayAlertWithTitle(title: String?, message: String?, buttonTitle: String, buttonHandler: VoidCompletionHandler?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: buttonTitle, style: .Default) { (alertAction) in
            buttonHandler?()
        }
        alert.addAction(action)
        UIApplication.sharedApplication().windows.first?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func displayAlertWithTitle(title: String?, message: String?, buttonTitle: String, buttonHandler: VoidCompletionHandler?, destructiveTitle: String, destructiveHandler: VoidCompletionHandler)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let destructiveAction = UIAlertAction(title: destructiveTitle, style: .Destructive) { (alertAction) in
            destructiveHandler()
        }
        alert.addAction(destructiveAction)
        let action = UIAlertAction(title: buttonTitle, style: .Default) { (alertAction) in
            buttonHandler?()
        }
        alert.addAction(action)
        UIApplication.sharedApplication().windows.first?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    class func openURLWithString(string: String)
    {
        if let url = NSURL(string: string)
        {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    class func stringDifferenceFromTimeStamp(timeStamp: Int) -> String
    {
        let before = NSDate(timeIntervalSince1970: NSTimeInterval(NSNumber(integer: timeStamp)))
        let today = NSDate()
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .Month, .Year]
        let dateComponents = NSCalendar.currentCalendar().components(unitFlags, fromDate: before, toDate: today, options: [])
        if dateComponents.year > 0
        {
            return "\(dateComponents.year) years ago"
        }
        else if dateComponents.month > 0
        {
            return "\(dateComponents.month) months ago"
        }
        else
        {
            let days = dateComponents.day
            if days > 7
            {
                let weeks = days / 7
                if weeks > 0
                {
                    return "\(weeks) weeks ago"
                }
                else
                {
                    return "\(days) days ago"
                }
            }
            else if days == 0
            {
                return "Today"
            }
            else
            {
                return "\(days) days ago"
            }
        }
    }
}