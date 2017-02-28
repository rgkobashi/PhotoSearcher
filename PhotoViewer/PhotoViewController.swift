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
    
    var photoViewModel: PhotoViewModel!
    
    fileprivate var hidden = false
    fileprivate var image: UIImage?
    
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
        camptionTextView.isSelectable = false
        
        if let likesCount = photoViewModel.likesCount, let date = photoViewModel.date, let commentsCount = photoViewModel.commentsCount
        {
            likesLabel.text = "\(likesCount) likes"
            dateLabel.text = Utilities.stringDifferenceFromTimeStamp(date)
            commentsLabel.text = "\(commentsCount) comments"
        }
        else
        {
            likesLabel.text = ""
            dateLabel.text = ""
            commentsLabel.text = ""
        }
        
        camptionTextView.text = photoViewModel.text
        downloadImage()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    @IBAction func actions(_ sender: AnyObject)
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
    
    fileprivate func close()
    {
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func share()
    {
        if let image = image
        {
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    fileprivate func hideShowElements()
    {
        if hidden
        {
            hidden = false
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                self.closeButton.alpha = 1
                self.shareButton.alpha = 1
                self.wrapperView.alpha = 1
            })
        }
        else
        {
            hidden = true
            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                self.closeButton.alpha = 0
                self.shareButton.alpha = 0
                self.wrapperView.alpha = 0
            })
        }
    }
    
    // MARK: - Methods for services calls
    
    fileprivate func downloadImage()
    {
        if let originalImage = photoViewModel.originalImage
        {
            activityIndicatorView.stopAnimating()
            image = originalImage
            imageDownloadSucceed()
        }
        else
        {
            photoViewModel.downloadOriginalImage({ [weak self] in
                self?.activityIndicatorView.stopAnimating()
                self?.image = self?.photoViewModel.originalImage
                self?.imageDownloadSucceed()
            }, failedHandler: { [weak self] (error) in
                self?.activityIndicatorView.stopAnimating()
                print("error = \(error)")
                self?.image = UIImage(named: "ImageError")
                self?.imageDownloadFailed()
            })
        }
    }
    
    fileprivate func imageDownloadSucceed()
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.tag = 1
        scrollView.contentSize = imageView.bounds.size
        scrollView.addSubview(imageView)
    }
    
    fileprivate func imageDownloadFailed()
    {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = image
        imageView.center = scrollView.center
        scrollView.addSubview(imageView)
        scrollView.isScrollEnabled = false
        shareButton.isUserInteractionEnabled = false
    }
}

extension PhotoViewController: UIScrollViewDelegate
{
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return scrollView.viewWithTag(1)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat)
    {
        if scale == 1
        {
            swipeGestureRecognizer.isEnabled = true
        }
        else
        {
            swipeGestureRecognizer.isEnabled = false
        }
    }
}
