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
            UserDefaults.standard.set(newValue, forKey: kKeyHasShownWelcome)
            UserDefaults.standard.synchronize()
        }
        get{
            return UserDefaults.standard.bool(forKey: kKeyHasShownWelcome)
        }
    }
}
