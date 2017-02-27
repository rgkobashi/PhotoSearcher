//
//  SearchResultsViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController
{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTermLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var searchTerm: String!
    private var topPosts = [Post]()
    private var mostRecent = [Post]()
    
    deinit
    {
        print("deinit SearchResultsViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchTermLabel.text = ""
        postsCountLabel.text = ""
        collectionView.dataSource = self
        collectionView.delegate = self
        callInstagramTagService()
    }
    
    @IBAction func buttonTapped(sender: UIButton)
    {
        if sender ==  backButton
        {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    private func callInstagramTagService()
    {
        let service = InstagramSearchPostService(tag: searchTerm)
        Loader.show()
        SessionManager.sharedInstance.start(service, suceedHandler: { [unowned self] (response) in
            Loader.dismiss()
            if let response = response
            {
                let result = PostUtility.parseInstagramPostResponse(response)
                self.searchTermLabel.text = "#\(result.name)"
                self.updatePostsCountLabel(result.count)
                self.topPosts.removeAll()
                self.topPosts.appendContentsOf(result.topPosts)
                self.mostRecent.removeAll()
                self.mostRecent.appendContentsOf(result.mostRecent)
                self.collectionView.reloadData()
            }
        }) { (error) in
            Loader.dismiss()
            print("error = \(error)")
            // TODO handler the errors
        }
    }
    
    private func updatePostsCountLabel(count: Int)
    {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

        let boldAttributed: NSMutableAttributedString!
        if let strCount = numberFormatter.stringFromNumber(count)
        {
            boldAttributed = NSMutableAttributedString(string: strCount, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(postsCountLabel.font.pointSize)])
        }
        else
        {
            boldAttributed = NSMutableAttributedString(string: "\(count)", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(postsCountLabel.font.pointSize)])
        }
        
        let normalAttributed: NSAttributedString!
        if count == 1
        {
            normalAttributed = NSAttributedString(string: " post")
        }
        else
        {
            normalAttributed = NSAttributedString(string: " posts")
        }
        
        boldAttributed.appendAttributedString(normalAttributed)
        postsCountLabel.attributedText = boldAttributed
    }
    
    private func downloadImageURL(imageURL: String, forCell cell: SearchResultsCollectionViewCell?)
    {
        Components.downloadImageFrom(imageURL, suceedHandler: { (result) in
            cell?.activityIndicatorView.stopAnimating()
            cell?.imageView.image = result as? UIImage
        }, failedHandler: { (error) in
            cell?.activityIndicatorView.stopAnimating()
            print("error = \(error)")
            // TODO handler error
        })
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showPhoto"
        {
            let photoVC = segue.destinationViewController as! PhotoViewController
            photoVC.post = sender as! Post
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return topPosts.count
        }
        else
        {
            return mostRecent.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("searchResultCell", forIndexPath: indexPath) as! SearchResultsCollectionViewCell
        weak var weakCell = cell
        if indexPath.section == 0
        {
            downloadImageURL(topPosts[indexPath.row].smallImageSrc, forCell: weakCell)
        }
        else
        {
            downloadImageURL(mostRecent[indexPath.row].smallImageSrc, forCell: weakCell)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
    {
        let collectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "headerReusableView", forIndexPath: indexPath)
        if collectionReusableView.subviews.count == 0
        {
            collectionReusableView.addSubview(UILabel(frame: CGRectMake(0, 0, collectionView.frame.size.width, 30)))
        }
        let label = collectionReusableView.subviews.first as! UILabel
        if indexPath.section == 0
        {
            label.text = "Top posts"
        }
        else
        {
            label.text = "Most recent"
        }
        return collectionReusableView
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0
        {
            let post = topPosts[indexPath.row]
            performSegueWithIdentifier("showPhoto", sender: post)
        }
        else
        {
            let post = mostRecent[indexPath.row]
            performSegueWithIdentifier("showPhoto", sender: post)
        }
    }
}
