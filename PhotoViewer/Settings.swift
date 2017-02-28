//
//  Settings.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 3/1/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

let kKeyHasShownWelcome = "keyHasShownWelcome"

class Settings
{
    static var hasShownWelcome: Bool{
        set{
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: kKeyHasShownWelcome)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        get{
            return NSUserDefaults.standardUserDefaults().boolForKey(kKeyHasShownWelcome)
        }
    }
}
