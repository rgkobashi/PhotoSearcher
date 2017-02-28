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
    private var content = ""
    private let startTime = NSDate()
    private var endTime: NSDate!
    private var durationTime: String!
    
    init(service: Service, request: NSURLRequest)
    {
        printInfoForService(service)
        createLogForRequest(request)
    }
    
    private func printInfoForService(service: Service)
    {
        var result = "\n*************Service info*************\n"
        result += "Service: \(String(service))\n"
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
    
    private func createLogForRequest(request: NSURLRequest)
    {
        content += "Resquest URL: \(request.URL!)\n"
        content += "Resquest headers: \(request.allHTTPHeaderFields!)\n"
        if let body = request.HTTPBody
        {
            if let string = String(data: body, encoding: NSUTF8StringEncoding)
            {
                content += "Request body: \n\(string)\n"
            }
        }
        
    }
    
    private func finishLog(response: NSHTTPURLResponse, body: AnyObject?)
    {
        content += "Status code: \(response.statusCode)\n"
        content += "Response headers: \(response.allHeaderFields)\n"
        if let body = body
        {
            do {
                let data = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
                if let string = String(data: data, encoding: NSUTF8StringEncoding)
                {
                    content += "Response body: \n\(string)\n"
                }
            } catch{
                
            }
        }
    }
    
    private func addErrorToLog(error: NSError)
    {
        content += "Error: \(error.localizedDescription)\n"
    }
    
    private func printLog()
    {
        let format = NSDateFormatter()
        format.dateFormat = "yyyy/MM/dd' 'HH:mm:ss.SSS"
        
        var result = "\n*************START: \(format.stringFromDate(startTime))*************\n"
        result += "Time: \(durationTime)ms\n"
        result += content
        result += "*************END: \(format.stringFromDate(endTime))*************\n"
        
        NSLog("%@", result)
    }
    
    func callFinished()
    {
        endTime = NSDate()
        let difference = endTime.timeIntervalSinceDate(startTime)
        durationTime = String(format: "%.0f", difference * 1000.0)
    }
    
    func finishWithResponse(response: NSHTTPURLResponse)
    {
        finishLog(response, body: nil)
        printLog()
    }
    
    func finishWithResponse(response: NSHTTPURLResponse, body: AnyObject)
    {
        finishLog(response, body: body)
        printLog()
    }
    
    func finishWithError(error: NSError, response: NSHTTPURLResponse, body: AnyObject)
    {
        finishLog(response, body: body)
        addErrorToLog(error)
        printLog()
    }
    
    func finishWithError(error: NSError)
    {
        addErrorToLog(error)
        printLog()
    }

}
