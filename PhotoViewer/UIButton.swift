//
//  UIButton.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

extension UIButton
{
    var substituteRegularFontName: String? {
        get {
            return self.titleLabel?.font.fontName
        }
        set {
            if let label = self.titleLabel, newValue = newValue
            {
                if label.font.fontName.containsString("Regular")
                {
                    label.font = UIFont(name: newValue, size: label.font.pointSize)
                }
            }
        }
    }
    
    var substituteBoldFontName: String? {
        get {
            return self.titleLabel?.font.fontName
        }
        set {
            if let label = self.titleLabel, newValue = newValue
            {
                if label.font.fontName.containsString("Bold")
                {
                    label.font = UIFont(name: newValue, size: label.font.pointSize)
                }
            }
        }
    }
}

