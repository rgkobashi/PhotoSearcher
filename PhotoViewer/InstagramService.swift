//
//  InstagramService.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class InstagramService: Service
{
    var requestType = RequestType.GET
    var contentType = ContentType.NONE
    var acceptType = AcceptType.JSON
    var timeOut: NSTimeInterval = 30
    var requestURL = ""
    var requestParams: [String: AnyObject]?
    var additionalHeaders: [String: String]?
    
    init(tag: String)
    {
        requestURL = kURLInstagram + "/" + tag + "/?__a=1"
    }
}
