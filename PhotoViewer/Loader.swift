//
//  Loader.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class Loader
{
    private static let activityIndicator = UIActivityIndicatorView()
    
    class func show()
    {
        let container = UIView()
        container.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        container.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let loadingView = UIView()
        loadingView.frame = CGRectMake(0, 0, 80, 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRectMake(0, 0, 40, 40)
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2, loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        UIApplication.sharedApplication().windows.first?.addSubview(container)
        
        activityIndicator.startAnimating()
    }
    
    class func dismiss()
    {
        if let loadingView = activityIndicator.superview
        {
            if let container = loadingView.superview
            {
                activityIndicator.removeFromSuperview()
                loadingView.removeFromSuperview()
                container.removeFromSuperview()
                activityIndicator.stopAnimating()
            }
        }
    }
}
