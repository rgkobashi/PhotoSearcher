//
//  SessionManager.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class SessionManager
{
    // TODO print logs
    static var sharedInstance = SessionManager()
    
    private var session: NSURLSession!
    
    init()
    {
        createSession()
    }
    
    // MARK: - Setup methods
    
    private func createSession()
    {
        let queue = NSOperationQueue()
        queue.name = "ServiceQueue"
        queue.maxConcurrentOperationCount = 4
        session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: queue)
    }
    
    // MARK: - Public methods
    
    func resetSession()
    {
        session = nil
        createSession()
    }
    
    func start(service: Service, suceedHandler: TMSuceedCompletionHandler, failedHandler: TMErrorCompletionHandler)
    {
        let request = createRequestForService(service)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if let error = error
                {
                    failedHandler(error)
                }
                else
                {
                    if let httpResponse = response as? NSHTTPURLResponse
                    {
                        if httpResponse.statusCode == 204
                        {
                            suceedHandler(nil)
                        }
                        else if let responseData = data
                        {
                            var contentType = ""
                            let headers = httpResponse.allHeaderFields
                            if let contentTypeHeader = headers["Content-Type"] as? String
                            {
                                let contentTypeArray = contentTypeHeader.componentsSeparatedByString(";")
                                if let first = contentTypeArray.first
                                {
                                    contentType = first
                                }
                            }
                            do
                            {
                                if let responseBody = try NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments) as? [String: AnyObject]
                                {
                                    if service.acceptType.rawValue == contentType
                                    {
                                        if httpResponse.statusCode == 200
                                        {
                                            if let error = responseBody["error"]
                                            {
                                                let error = NSError(domain: SessionManager.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: error])
                                                failedHandler(error)
                                            }
                                            else
                                            {
                                                suceedHandler(responseBody)
                                            }
                                        }
                                        else
                                        {
                                            let error = self.parseErrorResponse(responseBody, errorCode: httpResponse.statusCode)
                                            failedHandler(error)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: SessionManager.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:  "Invalid content type"])
                                        failedHandler(error)
                                    }
                                }
                                else if let responseBody = try NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments) as? [AnyObject]
                                {
                                    if service.acceptType.rawValue == contentType
                                    {
                                        if httpResponse.statusCode == 200
                                        {
                                            suceedHandler(responseBody)
                                        }
                                        else
                                        {
                                            let error = self.parseErrorResponse(responseBody, errorCode: httpResponse.statusCode)
                                            failedHandler(error)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: SessionManager.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid content type"])
                                        failedHandler(error)
                                    }
                                }
                                else
                                {
                                    let error = NSError(domain: SessionManager.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])
                                    failedHandler(error)
                                }
                            }
                            catch let error as NSError
                            {
                                failedHandler(error)
                            }
                            
                        }
                    }
                    else
                    {
                        let error = NSError(domain: SessionManager.errorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from the server"])
                        failedHandler(error)
                    }
                }
            })
        }).resume()
    }
    
    // MARK: - Helper methods
    
    private func createRequestForService(service: Service) -> NSURLRequest
    {
        let request = NSMutableURLRequest()
        
        request.URL = NSURL(string: service.requestURL)
        request.HTTPMethod = service.requestType.rawValue
        request.setValue(service.contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(service.acceptType.rawValue, forHTTPHeaderField: "Accept")
        request.timeoutInterval = service.timeOut
        
        for (key, value) in service.additionalHeaders
        {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if service.requestParams.count > 0
        {
            switch service.contentType {
            case .JSON:
                request.HTTPBody = createJSONBody(service.requestParams)
            case .FORM:
                request.HTTPBody = createFormBody(service.requestParams)
            case .XML:
                break
            case .NONE:
                break
            }
        }
        
        return request
    }
    
    private func parseErrorResponse(response: AnyObject, errorCode: Int) -> NSError
    {
        var err: NSError!
        
        if let response = response as? [String: AnyObject]
        {
            if let error = response["error"] as? String, let description = response["error_description"] as? String
            {
                err = NSError(domain: SessionManager.errorDomain, code: errorCode, userInfo: ["error": error, NSLocalizedDescriptionKey: description])
                return err
            }
        }
        
        err = NSError(domain: SessionManager.errorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey: "Could not parse error response"])
        
        return err
    }
    
    // MARK: - HTTP body formatters
    
    private func createJSONBody(params: [String: AnyObject]) -> NSData?
    {
        do
        {
            let json = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
            return json
        }
        catch let error as NSError
        {
            print("error creating JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createFormBody(params: [String: AnyObject]) -> NSData?
    {
        var body = ""
        
        for (key, value) in params
        {
            let encodeKey = encodeString(key)
            let encodeValue = encodeString(value as! String)
            body += encodeKey + "=" + encodeValue + "&"
        }
        
        return body.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    private func encodeString(string: String) -> String
    {
        if let encoded = string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
        {
            return encoded
        }
        return string
    }
    
}