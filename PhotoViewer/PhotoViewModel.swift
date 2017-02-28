//
//  PhotoViewModel.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 3/1/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewModel
{
    private var photo: Photo

    var text: String {
        return photo.text
    }
    
    private var originalImg: UIImage?
    var originalImage: UIImage? {
        return originalImg
    }
    
    private var thumbnailImg: UIImage?
    var thumbnailImage: UIImage? {
        return thumbnailImg
    }
    
    var likesCount: Int? {
        if let instagramPhoto = photo as? InstagramPhoto
        {
            return instagramPhoto.likesCount
        }
        else
        {
            return nil
        }
    }
    
    var date: Int? {
        if let instagramPhoto = photo as? InstagramPhoto
        {
            return instagramPhoto.date
        }
        else
        {
            return nil
        }
    }
    
    var commentsCount: Int? {
        if let instagramPhoto = photo as? InstagramPhoto
        {
            return instagramPhoto.commentsCount
        }
        else
        {
            return nil
        }
    }
    
    init (photo: Photo)
    {
        self.photo = photo
    }
    
    func downloadOriginalImage(_ suceedHandler: @escaping VoidCompletionHandler, failedHandler: @escaping ErrorCompletionHandler)
    {
        Utilities.downloadImageFrom(self.photo.originalUrl, suceedHandler: { [weak self] (result) in
            self?.originalImg = result as? UIImage
            suceedHandler()
            }, failedHandler: { (error) in
                failedHandler(error)
        })
    }
    
    func downloadThumbnailImage(_ suceedHandler: @escaping VoidCompletionHandler, failedHandler: @escaping ErrorCompletionHandler)
    {
        Utilities.downloadImageFrom(self.photo.thumbnailUrl, suceedHandler: { [weak self] (result) in
            self?.thumbnailImg = result as? UIImage
            suceedHandler()
            }, failedHandler: { (error) in
                failedHandler(error)
        })
    }
}
