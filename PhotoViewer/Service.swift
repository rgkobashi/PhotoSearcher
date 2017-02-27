//
//  Service.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

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

protocol Service
{
    var requestType: REQUEST_TYPE { get set }
    var contentType: CONTENT_TYPE { get set }
    var acceptType: ACCEPT_TYPE { get set }
    var timeOut: NSTimeInterval { get set }
    var requestURL: String { get set }
    var requestParams: [String: AnyObject]? { get set }
    var additionalHeaders: [String: String]? { get set }
}
