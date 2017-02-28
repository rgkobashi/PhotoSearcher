//
//  FlickrPhoto.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto: Photo
{
    var secret: String!
    var id: String!
    var server: String!
    var farm: Int!
}

class FlickrUtility
{
    class func parseResponse(_ response: AnyObject) -> [FlickrPhoto]
    {
        var resPhotos = [FlickrPhoto]()
        if let response = response as? [String : AnyObject]
        {
            if let photos = response["photos"] as? [String : AnyObject]
            {
                if let photo = photos["photo"] as? [AnyObject]
                {
                    for aPhoto in photo
                    {
                        let flickrPhoto = FlickrPhoto()
                        if let secret = aPhoto["secret"] as? String
                        {
                            flickrPhoto.secret = secret
                        }
                        if let id = aPhoto["id"] as? String
                        {
                            flickrPhoto.id = id
                        }
                        if let server = aPhoto["server"] as? String
                        {
                            flickrPhoto.server = server
                        }
                        if let farm = aPhoto["farm"] as? Int
                        {
                            flickrPhoto.farm = farm
                        }
                        if let title = aPhoto["title"] as? String
                        {
                            flickrPhoto.text = title
                        }
                        flickrPhoto.thumbnailUrl = thumbnailUrlFromFlickrPhoto(flickrPhoto)
                        flickrPhoto.originalUrl = originalUrlFromFlickrPhoto(flickrPhoto)
                        resPhotos.append(flickrPhoto)
                    }
                }
            }
        }
        return resPhotos
    }
    
    fileprivate class func thumbnailUrlFromFlickrPhoto(_ flickrPhoto: FlickrPhoto) -> String
    {
        let url = "https://farm\(flickrPhoto.farm).static.flickr.com/\(flickrPhoto.server)/\(flickrPhoto.id)_\(flickrPhoto.secret)_s.jpg"
        return url
    }
    
    fileprivate class func originalUrlFromFlickrPhoto(_ flickrPhoto: FlickrPhoto) -> String
    {
        let url = "https://farm\(flickrPhoto.farm).static.flickr.com/\(flickrPhoto.server)/\(flickrPhoto.id)_\(flickrPhoto.secret)_b.jpg"
        return url
    }
}
