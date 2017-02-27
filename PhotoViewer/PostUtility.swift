//
//  PostUtility.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation

class Post
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
    var smallImageSrc: String!
}

class PostUtility
{
    // TODO add pagination? check page_info field
    class func parseInstagramPostResponse(response: AnyObject) -> (name: String, count: Int, topPosts: [Post], mostRecent: [Post])
    {
        var resName = ""
        var resCount = 0
        var resTopPosts = [Post]()
        var resMostRecent = [Post]()
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
    
    private class func parseNodesSection(nodes: [AnyObject]) -> [Post]
    {
        var posts = [Post]()
        for node in nodes
        {
            let post = Post()
            if let videoViews = node["video_views"] as? Int
            {
                post.videoViews = videoViews
            }
            if let likes = node["likes"] as? [String : AnyObject]
            {
                if let count = likes["count"] as? Int
                {
                    post.likesCount = count
                }
            }
            if let caption = node["caption"] as? String
            {
                post.caption = caption
            }
            if let date = node["date"] as? Int
            {
                post.date = date
            }
            if let owner = node["owner"] as? [String : AnyObject]
            {
                if let id = owner["id"] as? String
                {
                    post.ownerId = id
                }
            }
            if let displaySrc = node["display_src"] as? String
            {
                post.displaySrc = displaySrc
                post.smallImageSrc = createSmallImageSrc(displaySrc)
            }
            if let dimensions = node["dimensions"] as? [String : AnyObject]
            {
                if let height = dimensions["height"] as? Int
                {
                    post.height = height
                }
                if let width = dimensions["width"] as? Int
                {
                    post.width = width
                }
            }
            if let code = node["code"] as? String
            {
                post.code = code
            }
            if let isVideo = node["is_video"] as? Bool
            {
                post.isVideo = isVideo
            }
            if let thumbnailSrc = node["thumbnail_src"] as? String
            {
                post.thumbnailSrc = thumbnailSrc
            }
            if let id = node["id"] as? String
            {
                post.id = id
            }
            if let comments = node["comments"] as? [String : AnyObject]
            {
                if let count = comments["count"] as? Int
                {
                    post.commentsCount = count
                }
            }
            posts.append(post)
        }
        return posts
    }
    
    private class func createSmallImageSrc(displaySrc: String) -> String
    {
        var words = displaySrc.componentsSeparatedByString("/")
        words[4] = "s" + kSmallImageSize
        return words.joinWithSeparator("/")
    }
}