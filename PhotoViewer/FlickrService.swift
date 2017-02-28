//
//  FlickrService.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class FlickrService: Service
{
    var requestType = RequestType.GET
    var contentType = ContentType.NONE
    var acceptType = AcceptType.JSON
    var timeOut: TimeInterval = 30
    var requestURL = ""
    var requestParams: [String: AnyObject]?
    var additionalHeaders: [String: String]?
    
    init(tag: String)
    {
        requestURL = kURLFlickr + "&api_key=" + kKeyFlickr + "&tags=" + tag
    }
}

