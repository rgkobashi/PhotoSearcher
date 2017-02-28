//
//  UILabel.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

extension UILabel
{
    var substituteRegularFontName: String {
        get {
            return self.font.fontName
        }
        set {
            if self.font.fontName.containsString("Regular")
            {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    
    var substituteBoldFontName: String {
        get {
            return self.font.fontName
        }
        set {
            if self.font.fontName.containsString("Bold")
            {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}
