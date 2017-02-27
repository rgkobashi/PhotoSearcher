//
//  PhotoViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var camptionTextView: UITextView!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var post: Post!
    
    private var hidden = false
    private var image: UIImage?
    
    //TODO swipe change to the next image
    
    deinit
    {
        print("deinit PhotoViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.zoomScale = 1
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        likesLabel.text = "\(post.likesCount) likes"
        dateLabel.text = NSDate(timeIntervalSince1970: NSTimeInterval(NSNumber(integer: post.date))).stringUTC()
        camptionTextView.text = post.caption
        commentsLabel.text = "\(post.commentsCount) comments"
        
        Components.downloadImageFrom(post.displaySrc, suceedHandler: { [unowned self] (result) in
            self.activityIndicatorView.stopAnimating()
            self.image = result as? UIImage
            self.updateScrollView()
        }, failedHandler: { (error) in
            self.activityIndicatorView.stopAnimating()
            print("error = \(error)")
            // TODO handler error
        })
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    @IBAction func actions(sender: AnyObject)
    {
        let object = sender as! NSObject
        switch object {
        case closeButton:
            close()
        case shareButton:
            share()
        case swipeGestureRecognizer:
            close()
        case tapGestureRecognizer:
            hideShowElements()
        default:
            break
        }
    }
    
    private func close()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func share()
    {
        if let image = image
        {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    private func hideShowElements()
    {
        if hidden
        {
            hidden = false
            UIView.animateWithDuration(0.3, animations: { [unowned self] in
                self.closeButton.alpha = 1
                self.shareButton.alpha = 1
                self.wrapperView.alpha = 1
            })
        }
        else
        {
            hidden = true
            UIView.animateWithDuration(0.3, animations: { [unowned self] in
                self.closeButton.alpha = 0
                self.shareButton.alpha = 0
                self.wrapperView.alpha = 0
            })
        }
    }
    
    private func updateScrollView()
    {
        let imageView = UIImageView(frame: CGRectMake(0, 0, view.frame.size.width, view.frame.size.height))
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        imageView.tag = 1
        scrollView.contentSize = imageView.bounds.size
        scrollView.addSubview(imageView)
    }
}

extension PhotoViewController: UIScrollViewDelegate
{
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return scrollView.viewWithTag(1)
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat)
    {
        if scale == 1
        {
            swipeGestureRecognizer.enabled = true
        }
        else
        {
            swipeGestureRecognizer.enabled = false
        }
    }
}
