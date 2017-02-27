//
//  TagUtility.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class Tag
{
    var videoViews: Int?
    var likesCount: Int!
    var caption: String!
    var date: Int!
    var ownerId: String!
    var displaySrc: String!
    var height: Int!
    var width: Int!
    var code: String!
    var isVideo: Bool!
    var thumbnailSrc: String!
    var id: String!
    var commentsCount: Int!
    var commentsDisabled: Bool?
}

class TagUtility
{
    // TODO add pagination? check page_info field
    class func parseInstagramTagResponse(response: AnyObject) -> (name: String, count: Int, topPosts: [Tag], mostRecent: [Tag])
    {
        var resName = ""
        var resCount = 0
        var resTopPosts = [Tag]()
        var resMostRecent = [Tag]()
        if let response = response as? [String : AnyObject]
        {
            if let tag = response["tag"] as? [String : AnyObject]
            {
                if let name = tag["name"] as? String
                {
                    resName = name
                }
                if let topPosts = tag["top_posts"] as? [String : AnyObject]
                {
                    if let nodes = topPosts["nodes"] as? [AnyObject]
                    {
                        resTopPosts.appendContentsOf(parseNodesSection(nodes))
                    }
                }
                if let media = tag["media"] as? [String : AnyObject]
                {
                    if let count = media["count"] as? Int
                    {
                        resCount = count
                    }
                    if let nodes = media["nodes"] as? [AnyObject]
                    {
                        resMostRecent.appendContentsOf(parseNodesSection(nodes))
                    }
                }
            }
        }
        return (resName, resCount, resTopPosts, resMostRecent)
    }
    
    private class func parseNodesSection(nodes: [AnyObject]) -> [Tag]
    {
        var tags = [Tag]()
        for node in nodes
        {
            let tag = Tag()
            if let videoViews = node["video_views"] as? Int
            {
                tag.videoViews = videoViews
            }
            if let likes = node["likes"] as? [String : AnyObject]
            {
                if let count = likes["count"] as? Int
                {
                    tag.likesCount = count
                }
            }
            if let caption = node["caption"] as? String
            {
                tag.caption = caption
            }
            if let date = node["date"] as? Int
            {
                tag.date = date
            }
            if let owner = node["owner"] as? [String : AnyObject]
            {
                if let id = owner["id"] as? String
                {
                    tag.ownerId = id
                }
            }
            if let displaySrc = node["display_src"] as? String
            {
                tag.displaySrc = displaySrc
            }
            if let dimensions = node["dimensions"] as? [String : AnyObject]
            {
                if let height = dimensions["height"] as? Int
                {
                    tag.height = height
                }
                if let width = dimensions["width"] as? Int
                {
                    tag.width = width
                }
            }
            if let code = node["code"] as? String
            {
                tag.code = code
            }
            if let isVideo = node["is_video"] as? Bool
            {
                tag.isVideo = isVideo
            }
            if let thumbnailSrc = node["thumbnail_src"] as? String
            {
                tag.thumbnailSrc = thumbnailSrc
            }
            if let id = node["id"] as? String
            {
                tag.id = id
            }
            if let comments = node["comments"] as? [String : AnyObject]
            {
                if let count = comments["count"] as? Int
                {
                    tag.commentsCount = count
                }
            }
            tags.append(tag)
        }
        return tags
    }
}