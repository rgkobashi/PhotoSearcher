//
//  InstagramPhoto.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class InstagramPhoto: Photo
{
    var likesCount = 0
    var date = 0
    var commentsCount = 0
}

class InstagramUtility
{
    class func parseResponse(_ response: AnyObject) -> (top: [InstagramPhoto], mostRecent: [InstagramPhoto])
    {
        var resTop = [InstagramPhoto]()
        var resMostRecent = [InstagramPhoto]()
        if let response = response as? [String : AnyObject]
        {
            if let tag = response["tag"] as? [String : AnyObject]
            {
                if let topPosts = tag["top_posts"] as? [String : AnyObject]
                {
                    if let nodes = topPosts["nodes"] as? [AnyObject]
                    {
                        resTop.append(contentsOf: parseSectionNodes(nodes))
                    }
                }
                if let media = tag["media"] as? [String : AnyObject]
                {
                    if let nodes = media["nodes"] as? [AnyObject]
                    {
                        resMostRecent.append(contentsOf: parseSectionNodes(nodes))
                    }
                }
            }
        }
        return (resTop, resMostRecent)
    }
    
    fileprivate class func parseSectionNodes(_ nodes: [AnyObject]) -> [InstagramPhoto]
    {
        var instagramPhotos = [InstagramPhoto]()
        for node in nodes
        {
            let instagramPhoto = InstagramPhoto()
            if let likes = node["likes"] as? [String : AnyObject]
            {
                if let count = likes["count"] as? Int
                {
                    instagramPhoto.likesCount = count
                }
            }
            if let caption = node["caption"] as? String
            {
                instagramPhoto.text = caption
            }
            if let date = node["date"] as? Int
            {
                instagramPhoto.date = date
            }
            if let displaySrc = node["display_src"] as? String
            {
                instagramPhoto.originalUrl = displaySrc
                instagramPhoto.thumbnailUrl = thumbnailUrlFromInstagramPhoto(instagramPhoto)
            }
            if let comments = node["comments"] as? [String : AnyObject]
            {
                if let count = comments["count"] as? Int
                {
                    instagramPhoto.commentsCount = count
                }
            }
            instagramPhotos.append(instagramPhoto)
        }
        return instagramPhotos
    }
    
    fileprivate class func thumbnailUrlFromInstagramPhoto(_ instagramPhoto: InstagramPhoto) -> String
    {
        var words = instagramPhoto.originalUrl.components(separatedBy: "/")
        words[4] = "s" + kThumbnailImageSize
        return words.joined(separator: "/")
    }
}
