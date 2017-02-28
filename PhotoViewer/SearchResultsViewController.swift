//
//  SearchResultsViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

enum ServiceCalled: String
{
    case Instagram = "Instagram"
    case Flickr = "Flickr"
}

class SearchResultsViewController: UIViewController
{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTermLabel: UILabel!
    @IBOutlet weak var photosCountLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var searchTerm: String!
    private var top = [Photo]()
    private var mostRecent = [Photo]()
    
    deinit
    {
        print("deinit SearchResultsViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchTermLabel.text = ""
        photosCountLabel.text = ""
        collectionView.dataSource = self
        collectionView.delegate = self
        segmentedControl.setTitle(ServiceCalled.Instagram.rawValue, forSegmentAtIndex: 0)
        segmentedControl.setTitle(ServiceCalled.Flickr.rawValue, forSegmentAtIndex: 1)
        callService(.Instagram)
    }
    
    @IBAction func actions(sender: AnyObject)
    {
        let object = sender as! NSObject
        switch object {
        case backButton:
            back()
        case segmentedControl:
            if segmentedControl.selectedSegmentIndex == 0
            {
                callService(.Instagram)
            }
            else
            {
                callService(.Flickr)
            }
        default:
            break
        }
    }
    
    private func back()
    {
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func callService(serviceCalled: ServiceCalled)
    {
        let service: Service!
        switch serviceCalled {
        case .Instagram:
            service = InstagramService(tag: searchTerm)
        case .Flickr:
            service = FlickrService(tag: searchTerm)
        }
        Loader.show()
        SessionManager.sharedInstance.start(service, suceedHandler: { [weak self] (response) in
            Loader.dismiss()
            if let response = response
            {
                self?.successServiceCalled(serviceCalled, response: response)
            }
            else
            {
                self?.failedServiceCalled(nil)
            }
        }) { [weak self] (error) in
            Loader.dismiss()
            self?.failedServiceCalled(error)
        }
    }
    
    private func successServiceCalled(serviceCalled: ServiceCalled, response: AnyObject)
    {
        collectionView.setContentOffset(CGPointZero, animated: true)
        searchTermLabel.text = "#\(self.searchTerm)"
        top.removeAll()
        mostRecent.removeAll()
        switch serviceCalled {
        case .Instagram:
            let result = InstagramUtility.parseResponse(response)
            top.appendContentsOf(result.top.map{$0 as Photo})
            mostRecent.appendContentsOf(result.mostRecent.map{$0 as Photo})
            updatePhotosCountLabel(result.top.count + result.mostRecent.count)
        case .Flickr:
            let result = FlickrUtility.parseResponse(response)
            top.appendContentsOf(result.map{$0 as Photo})
            updatePhotosCountLabel(result.count)
        }
        collectionView.reloadData()
    }
    
    private func failedServiceCalled(error: NSError?)
    {
        Loader.dismiss()
        print("error = \(error)")
        Components.displayAlertWithTitle("Error", message: "Error searching for photos, please try again.", buttonTitle: "Accept", buttonHandler: { [weak self] in
            self?.back()
        })
    }
    
    private func updatePhotosCountLabel(count: Int)
    {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle

        let boldAttributed: NSMutableAttributedString!
        if let strCount = numberFormatter.stringFromNumber(count)
        {
            boldAttributed = NSMutableAttributedString(string: strCount, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(photosCountLabel.font.pointSize)])
        }
        else
        {
            boldAttributed = NSMutableAttributedString(string: "\(count)", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(photosCountLabel.font.pointSize)])
        }
        
        let normalAttributed = NSAttributedString(string: " photos")
        boldAttributed.appendAttributedString(normalAttributed)
        photosCountLabel.attributedText = boldAttributed
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showPhoto"
        {
            let indexPath = sender as! NSIndexPath
            let photo: Photo!
            if indexPath.section == 0
            {
                photo = top[indexPath.row]
            }
            else
            {
                photo = mostRecent[indexPath.row]
            }
            let photoVC = segue.destinationViewController as! PhotoViewController
            photoVC.photo = photo
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        if mostRecent.count > 0
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if section == 0
        {
            return top.count
        }
        else
        {
            return mostRecent.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("searchResultCell", forIndexPath: indexPath) as! SearchResultsCollectionViewCell
        var photo: Photo!
        if indexPath.section == 0
        {
            photo = top[indexPath.row]
        }
        else
        {
            photo = mostRecent[indexPath.row]
        }
        
        if let image = photo.thumbnailImage
        {
            cell.activityIndicatorView.stopAnimating()
            cell.imageView.image = image
        }
        else
        {
            photo.downloadThumbnailImage({ [weak cell] in
                cell?.activityIndicatorView.stopAnimating()
                cell?.imageView.image = photo.thumbnailImage
            }, failedHandler: { [weak cell] (error) in
                cell?.activityIndicatorView.stopAnimating()
                cell?.imageView.image = UIImage(named: "BrokenImage")
            })
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
            label.text = "Top photos"
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
        performSegueWithIdentifier("showPhoto", sender: indexPath)
    }
}
