//
//  Utility.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

protocol Photo
{
    var text: String { get set }
    var thumbnailUrl: String { get set }
    var originalUrl: String { get set }
}