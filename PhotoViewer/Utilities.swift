//
//  Utilities.swift
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

class Utilities
{
    class func downloadImageFrom(_ urlString: String, suceedHandler: @escaping SuceedCompletionHandler, failedHandler: @escaping ErrorCompletionHandler)
    {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async { () -> Void in
            let url = URL(string: urlString)
            if let url = url
            {
                let data = try? Data(contentsOf: url)
                if let data = data
                {
                    let image = UIImage(data: data)
                    if let image = image
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            suceedHandler(image)
                        })
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Image could not be initialized from the specified data."])
                            failedHandler(error)
                        })
                    }
                }
                else
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from the server."])
                        failedHandler(error)
                    })
                }
            }
            else
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "URL string malformed."])
                    failedHandler(error)
                })
            }
        }
    }
    
    class func displayAlertWithTitle(_ title: String?, message: String?, buttonTitle: String, buttonHandler: VoidCompletionHandler?)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { (alertAction) in
            buttonHandler?()
        }
        alert.addAction(action)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    class func displayAlertWithTitle(_ title: String?, message: String?, buttonTitle: String, buttonHandler: VoidCompletionHandler?, destructiveTitle: String, destructiveHandler: @escaping VoidCompletionHandler)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { (alertAction) in
            destructiveHandler()
        }
        alert.addAction(destructiveAction)
        let action = UIAlertAction(title: buttonTitle, style: .default) { (alertAction) in
            buttonHandler?()
        }
        alert.addAction(action)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    class func openURLWithString(_ string: String)
    {
        if let url = URL(string: string)
        {
            UIApplication.shared.openURL(url)
        }
    }
    
    class func stringDifferenceFromTimeStamp(_ timeStamp: Int) -> String
    {
        let before = Date(timeIntervalSince1970: TimeInterval(NSNumber(value: timeStamp as Int)))
        let today = Date()
        let unitFlags: NSCalendar.Unit = [.hour, .day, .month, .year]
        let dateComponents = (Calendar.current as NSCalendar).components(unitFlags, from: before, to: today, options: [])
        if dateComponents.year! > 0
        {
            return "\(dateComponents.year) years ago"
        }
        else if dateComponents.month! > 0
        {
            return "\(dateComponents.month) months ago"
        }
        else
        {
            let days = dateComponents.day
            if days! > 7
            {
                let weeks = days! / 7
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
