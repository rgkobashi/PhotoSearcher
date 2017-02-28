//
//  ServiceTracker.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class ServiceTracker
{
    fileprivate var content = ""
    fileprivate let startTime = Date()
    fileprivate var endTime: Date!
    fileprivate var durationTime: String!
    
    init(service: Service, request: URLRequest)
    {
        printInfoForService(service)
        createLogForRequest(request)
    }
    
    // MARK: - Private methods
    
    fileprivate func printInfoForService(_ service: Service)
    {
        var result = "\n*************Service info*************\n"
        result += "Service: \(String(describing: service))\n"
        result += "Resquest URL: \(service.requestURL)\n"
        result += "Resquest type: \(service.requestType)\n"
        result += "Content type: \(service.contentType)\n"
        result += "Accept type: \(service.acceptType)\n"
        result += "Timeout: \(service.timeOut)\n"
        if let requestParams = service.requestParams
        {
            result += "Request params: \n\(requestParams)\n"
        }
        else
        {
            result += "Request params: \n"
        }
        if let additionalHeaders = service.additionalHeaders
        {
            result += "Additional headers: \n\(additionalHeaders)\n"
        }
        else
        {
            result += "Additional headers: \n"
        }
        result += "***************************************\n"
        NSLog("%@", result)
    }
    
    fileprivate func createLogForRequest(_ request: URLRequest)
    {
        content += "Resquest URL: \(request.url!)\n"
        content += "Resquest headers: \(request.allHTTPHeaderFields!)\n"
        if let body = request.httpBody
        {
            if let string = String(data: body, encoding: String.Encoding.utf8)
            {
                content += "Request body: \n\(string)\n"
            }
        }
        
    }
    
    fileprivate func finishLog(_ response: HTTPURLResponse, body: AnyObject?)
    {
        content += "Status code: \(response.statusCode)\n"
        content += "Response headers: \(response.allHeaderFields)\n"
        if let body = body
        {
            do {
                let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                if let string = String(data: data, encoding: String.Encoding.utf8)
                {
                    content += "Response body: \n\(string)\n"
                }
            } catch{
                
            }
        }
    }
    
    fileprivate func addErrorToLog(_ error: NSError)
    {
        content += "Error: \(error.localizedDescription)\n"
    }
    
    fileprivate func printLog()
    {
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd' 'HH:mm:ss.SSS"
        
        var result = "\n*************START: \(format.string(from: startTime))*************\n"
        result += "Time: \(durationTime)ms\n"
        result += content
        result += "*************END: \(format.string(from: endTime))*************\n"
        
        NSLog("%@", result)
    }
    
    // MARK: - Public methods
    
    func callFinished()
    {
        endTime = Date()
        let difference = endTime.timeIntervalSince(startTime)
        durationTime = String(format: "%.0f", difference * 1000.0)
    }
    
    func finishWithResponse(_ response: HTTPURLResponse)
    {
        finishLog(response, body: nil)
        printLog()
    }
    
    func finishWithResponse(_ response: HTTPURLResponse, body: AnyObject)
    {
        finishLog(response, body: body)
        printLog()
    }
    
    func finishWithError(_ error: NSError, response: HTTPURLResponse, body: AnyObject)
    {
        finishLog(response, body: body)
        addErrorToLog(error)
        printLog()
    }
    
    func finishWithError(_ error: NSError)
    {
        addErrorToLog(error)
        printLog()
    }

}
