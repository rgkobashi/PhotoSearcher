//
//  Service.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

// TODO change this for POP

enum REQUEST_TYPE: String
{
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
}

enum CONTENT_TYPE: String
{
    case XML = "application/xml"
    case JSON = "application/json"
    case FORM = "application/x-www-form-urlencoded"
    case NONE = ""
}

enum ACCEPT_TYPE: String
{
    case XML = "application/xml"
    case JSON = "application/json"
    case HTML = "text/html"
    case PLAIN = "text/plain"
    case JAVASCRIPT = "text/javascript"
    case NONE = ""
}

class Service
{
    var requestType: REQUEST_TYPE = .GET
    var contentType: CONTENT_TYPE = .JSON
    var acceptType: ACCEPT_TYPE = .JSON
    var timeOut: NSTimeInterval = 30
    var requestURL = ""
    var requestParams = [String: AnyObject]()
    var additionalHeaders = [String: String]()
}
