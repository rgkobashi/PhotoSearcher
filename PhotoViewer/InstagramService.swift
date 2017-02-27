//
//  InstagramService.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class InstagramService: Service
{
    init(tag: String)
    {
        super.init()
        requestType = .GET
        contentType = .NONE
        acceptType = .JSON
        requestURL = kURLInstagram + "/\(tag)/?__a=1"
    }
}
