//
//  Utility.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class Photo
{
    var text = ""
    var thumbnailUrl = ""
    var originalUrl = ""
    
    var thumbnailImage: UIImage?
    
    func downloadThumbnailImage(suceedHandler: VoidCompletionHandler, failedHandler: ErrorCompletionHandler)
    {
        Components.downloadImageFrom(thumbnailUrl, suceedHandler: { [weak self] (result) in
            self?.thumbnailImage = result as? UIImage
            suceedHandler()
        }, failedHandler: { (error) in
            failedHandler(error)
        })
    }
}
