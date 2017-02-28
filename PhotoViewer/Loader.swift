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
    fileprivate static let activityIndicator = UIActivityIndicatorView()
    
    class func show()
    {
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        container.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        UIApplication.shared.windows.first?.addSubview(container)
        
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
