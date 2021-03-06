//
//  Service.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

enum RequestType: String
{
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case HEAD = "HEAD"
}

enum ContentType: String
{
    case XML = "application/xml"
    case JSON = "application/json"
    case FORM = "application/x-www-form-urlencoded"
    case NONE = ""
}

enum AcceptType: String
{
    case XML = "application/xml"
    case JSON = "application/json"
    case HTML = "text/html"
    case PLAIN = "text/plain"
    case JAVASCRIPT = "text/javascript"
    case NONE = ""
}

/// The classes which implement Service protocol can be used on SessionManager class.
/// Every class which implements Service protocol can be considered as a Web Service. This the instanse can be sent to start method from SessionManager class.
protocol Service
{
    var requestType: RequestType { get set }
    var contentType: ContentType { get set }
    var acceptType: AcceptType { get set }
    var timeOut: TimeInterval { get set }
    var requestURL: String { get set }
    var requestParams: [String: AnyObject]? { get set }
    var additionalHeaders: [String: String]? { get set }
}
