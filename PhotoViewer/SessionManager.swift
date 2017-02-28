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
    static var sharedInstance = SessionManager()
    
    fileprivate var session: URLSession!
    
    init()
    {
        createSession()
    }
    
    // MARK: - Setup methods
    
    fileprivate func createSession()
    {
        let queue = OperationQueue()
        queue.name = "ServiceQueue"
        queue.maxConcurrentOperationCount = 4
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: queue)
    }
    
    // MARK: - Public methods
    
    func resetSession()
    {
        session = nil
        createSession()
    }
    
    func start(_ service: Service, suceedHandler: @escaping SuceedCompletionHandler, failedHandler: @escaping ErrorCompletionHandler)
    {
        let request = createRequestForService(service)
        var serviceTracker: ServiceTracker?
        #if !PROD
            serviceTracker = ServiceTracker(service: service, request: request)
        #endif
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                serviceTracker?.callFinished()
                if let error = error
                {
                    serviceTracker?.finishWithError(error)
                    failedHandler(error as NSError)
                }
                else
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        if httpResponse.statusCode == 204
                        {
                            serviceTracker?.finishWithResponse(httpResponse)
                            suceedHandler(nil)
                        }
                        else if let responseData = data
                        {
                            var contentType = ""
                            let headers = httpResponse.allHeaderFields
                            if let contentTypeHeader = headers["Content-Type"] as? String
                            {
                                let contentTypeArray = contentTypeHeader.components(separatedBy: ";")
                                if let first = contentTypeArray.first
                                {
                                    contentType = first
                                }
                            }
                            do
                            {
                                if let responseBody = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: AnyObject]
                                {
                                    if service.acceptType.rawValue == contentType
                                    {
                                        if httpResponse.statusCode == 200
                                        {
                                            if let error = responseBody["error"]
                                            {
                                                let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: error])
                                                serviceTracker?.finishWithError(error, response: httpResponse, body: responseBody)
                                                failedHandler(error)
                                            }
                                            else
                                            {
                                                serviceTracker?.finishWithResponse(httpResponse, body: responseBody)
                                                suceedHandler(responseBody as AnyObject?)
                                            }
                                        }
                                        else
                                        {
                                            let error = self.parseErrorResponse(responseBody as AnyObject, errorCode: httpResponse.statusCode)
                                            serviceTracker?.finishWithError(error, response: httpResponse, body: responseBody)
                                            failedHandler(error)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey:  "Invalid content type"])
                                        serviceTracker?.finishWithError(error, response: httpResponse, body: responseBody)
                                        failedHandler(error)
                                    }
                                }
                                else if let responseBody = try JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [AnyObject]
                                {
                                    if service.acceptType.rawValue == contentType
                                    {
                                        if httpResponse.statusCode == 200
                                        {
                                            serviceTracker?.finishWithResponse(httpResponse, body: responseBody)
                                            suceedHandler(responseBody as AnyObject?)
                                        }
                                        else
                                        {
                                            let error = self.parseErrorResponse(responseBody as AnyObject, errorCode: httpResponse.statusCode)
                                            serviceTracker?.finishWithError(error, response: httpResponse, body: responseBody)
                                            failedHandler(error)
                                        }
                                    }
                                    else
                                    {
                                        let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid content type"])
                                        serviceTracker?.finishWithError(error, response: httpResponse, body: responseBody)
                                        failedHandler(error)
                                    }
                                }
                                else
                                {
                                    let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])
                                    serviceTracker?.finishWithError(error)
                                    failedHandler(error)
                                }
                            }
                            catch let error as NSError
                            {
                                serviceTracker?.finishWithError(error)
                                failedHandler(error)
                            }
                            
                        }
                    }
                    else
                    {
                        let error = NSError(domain: kErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from the server"])
                        serviceTracker?.finishWithError(error)
                        failedHandler(error)
                    }
                }
            })
        }).resume()
    }
    
    // MARK: - Helper methods
    
    fileprivate func createRequestForService(_ service: Service) -> URLRequest
    {
        let request = NSMutableURLRequest()
        
        request.url = URL(string: service.requestURL)
        request.httpMethod = service.requestType.rawValue
        request.setValue(service.contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.setValue(service.acceptType.rawValue, forHTTPHeaderField: "Accept")
        request.timeoutInterval = service.timeOut
        
        if let additionalHeaders = service.additionalHeaders
        {
            for (key, value) in additionalHeaders
            {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let requestParams = service.requestParams, requestParams.count > 0
        {
            switch service.contentType {
            case .JSON:
                request.httpBody = createJSONBody(requestParams)
            case .FORM:
                request.httpBody = createFormBody(requestParams)
            case .XML:
                break
            case .NONE:
                break
            }
        }
        
        return request as URLRequest
    }
    
    fileprivate func parseErrorResponse(_ response: AnyObject, errorCode: Int) -> NSError
    {
        var err: NSError!
        
        if let response = response as? [String: AnyObject]
        {
            if let error = response["error"] as? String, let description = response["error_description"] as? String
            {
                err = NSError(domain: kErrorDomain, code: errorCode, userInfo: ["error": error, NSLocalizedDescriptionKey: description])
                return err
            }
        }
        
        err = NSError(domain: kErrorDomain, code: errorCode, userInfo: [NSLocalizedDescriptionKey: "Could not parse error response"])
        
        return err
    }
    
    // MARK: - HTTP body formatters
    
    fileprivate func createJSONBody(_ params: [String: AnyObject]) -> Data?
    {
        do
        {
            let json = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            return json
        }
        catch let error as NSError
        {
            print("error creating JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    fileprivate func createFormBody(_ params: [String: AnyObject]) -> Data?
    {
        var body = ""
        
        for (key, value) in params
        {
            let encodeKey = encodeString(key)
            let encodeValue = encodeString(value as! String)
            body += encodeKey + "=" + encodeValue + "&"
        }
        
        return body.data(using: String.Encoding.utf8)
    }
    
    fileprivate func encodeString(_ string: String) -> String
    {
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        {
            return encoded
        }
        return string
    }
    
}
