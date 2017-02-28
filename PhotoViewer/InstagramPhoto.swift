//
//  InstagramPhoto.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class InstagramPhoto: Photo
{
    var text = ""
    var thumbnailUrl = ""
    var originalUrl = ""
    
    var likesCount: Int!
    var date: Int!
    var commentsCount: Int!
}

class InstagramUtility
{
    class func parseResponse(response: AnyObject) -> (top: [InstagramPhoto], mostRecent: [InstagramPhoto])
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
                        resTop.appendContentsOf(parseNodesSection(nodes))
                    }
                }
                if let media = tag["media"] as? [String : AnyObject]
                {
                    if let nodes = media["nodes"] as? [AnyObject]
                    {
                        resMostRecent.appendContentsOf(parseNodesSection(nodes))
                    }
                }
            }
        }
        return (resTop, resMostRecent)
    }
    
    private class func parseNodesSection(nodes: [AnyObject]) -> [InstagramPhoto]
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
                instagramPhoto.thumbnailUrl = createThumbnailUrl(instagramPhoto)
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
    
    private class func createThumbnailUrl(instagramPhoto: InstagramPhoto) -> String
    {
        var words = instagramPhoto.originalUrl.componentsSeparatedByString("/")
        words[4] = "s" + kSmallImageSize
        return words.joinWithSeparator("/")
    }
}