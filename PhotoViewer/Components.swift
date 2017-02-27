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
}