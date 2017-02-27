//
//  InstagramSearchPostService.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class InstagramSearchPostService: Service
{
    var requestType = REQUEST_TYPE.GET
    var contentType = CONTENT_TYPE.NONE
    var acceptType = ACCEPT_TYPE.JSON
    var timeOut: NSTimeInterval = 30
    var requestURL = ""
    var requestParams: [String: AnyObject]?
    var additionalHeaders: [String: String]?
    
    init(tag: String)
    {
        requestURL = kURLInstagramTag + "/\(tag)/?__a=1"
    }
}
