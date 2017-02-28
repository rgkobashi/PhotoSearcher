//
//  SearchResultsViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

enum ServiceType: String
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
    
    var searchTerm = ""
    fileprivate var top = [PhotoViewModel]()
    fileprivate var mostRecent = [PhotoViewModel]()
    
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
        segmentedControl.setTitle(ServiceType.Instagram.rawValue, forSegmentAt: 0)
        segmentedControl.setTitle(ServiceType.Flickr.rawValue, forSegmentAt: 1)
        callServiceType(.Instagram)
    }
    
    @IBAction func actions(_ sender: AnyObject)
    {
        let object = sender as! NSObject
        switch object {
        case backButton:
            back()
        case segmentedControl:
            if segmentedControl.selectedSegmentIndex == 0
            {
                callServiceType(.Instagram)
            }
            else
            {
                callServiceType(.Flickr)
            }
        default:
            break
        }
    }
    
    fileprivate func back()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func updatePhotosCountLabel(_ count: Int)
    {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        
        let boldAttributed: NSMutableAttributedString!
        if let strCount = numberFormatter.string(from: count as NSNumber)
        {
            boldAttributed = NSMutableAttributedString(string: strCount, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: photosCountLabel.font.pointSize)])
        }
        else
        {
            boldAttributed = NSMutableAttributedString(string: "\(count)", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: photosCountLabel.font.pointSize)])
        }
        
        let normalAttributed = NSAttributedString(string: " photos")
        boldAttributed.append(normalAttributed)
        photosCountLabel.attributedText = boldAttributed
    }
    
    // MARK: - Methods for services calls
    
    fileprivate func callServiceType(_ serviceType: ServiceType)
    {
        let service: Service!
        switch serviceType {
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
                self?.serviceCallSucceedWithType(serviceType, response: response)
            }
            else
            {
                self?.serviceCallFailedWithError(nil)
            }
        }) { [weak self] (error) in
            Loader.dismiss()
            self?.serviceCallFailedWithError(error)
        }
    }
    
    fileprivate func serviceCallSucceedWithType(_ type: ServiceType, response: AnyObject)
    {
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        searchTermLabel.text = "#\(self.searchTerm)"
        top.removeAll()
        mostRecent.removeAll()
        switch type {
        case .Instagram:
            let result = InstagramUtility.parseResponse(response)
            for photo in result.top
            {
                let photoViewModel = PhotoViewModel(photo: photo)
                top.append(photoViewModel)
            }
            for photo in result.mostRecent
            {
                let photoViewModel = PhotoViewModel(photo: photo)
                mostRecent.append(photoViewModel)
            }
            updatePhotosCountLabel(result.top.count + result.mostRecent.count)
        case .Flickr:
            let result = FlickrUtility.parseResponse(response)
            for photo in result
            {
                let photoViewModel = PhotoViewModel(photo: photo)
                top.append(photoViewModel)
            }
            updatePhotosCountLabel(result.count)
        }
        collectionView.reloadData()
    }
    
    fileprivate func serviceCallFailedWithError(_ error: Error?)
    {
        Loader.dismiss()
        print("error = \(error)")
        Utilities.displayAlertWithTitle("Error", message: "Error searching for photos, please try again.", buttonTitle: "Accept", buttonHandler: { [weak self] in
            self?.back()
        })
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showPhoto"
        {
            let indexPath = sender as! IndexPath
            let photoViewModel: PhotoViewModel!
            if indexPath.section == 0
            {
                photoViewModel = top[indexPath.row]
            }
            else
            {
                photoViewModel = mostRecent[indexPath.row]
            }
            let photoVC = segue.destination as! PhotoViewController
            photoVC.photoViewModel = photoViewModel
        }
    }
}

extension SearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchResultCell", for: indexPath) as! SearchResultsCollectionViewCell
        var photoViewModel: PhotoViewModel!
        if indexPath.section == 0
        {
            photoViewModel = top[indexPath.row]
        }
        else
        {
            photoViewModel = mostRecent[indexPath.row]
        }
        
        if let image = photoViewModel.thumbnailImage
        {
            cell.activityIndicatorView.stopAnimating()
            cell.imageView.image = image
        }
        else
        {
            photoViewModel.downloadThumbnailImage({ [weak cell] in
                cell?.activityIndicatorView.stopAnimating()
                cell?.imageView.image = photoViewModel.thumbnailImage
            }, failedHandler: { [weak cell] (error) in
                cell?.activityIndicatorView.stopAnimating()
                cell?.imageView.image = UIImage(named: "ImageError")
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        var collectionReusableView: UICollectionReusableView!
        if kind == UICollectionElementKindSectionHeader
        {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerReusableView", for: indexPath) as! HeaderCollectionReusableView
            if indexPath.section == 0
            {
                headerView.label.text = "Top photos"
            }
            else
            {
                headerView.label.text = "Most recent"
            }
            collectionReusableView = headerView
        }
        else
        {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerReusableView", for: indexPath) as! FooterCollectionReusableView
            if mostRecent.count == 0 && indexPath.section == 0
            {
                footerView.view.isHidden = true
            }
            else if mostRecent.count > 0 && indexPath.section == 1
            {
                footerView.view.isHidden = true
            }
            else
            {
                footerView.view.isHidden = false
            }
            collectionReusableView = footerView
        }
        return collectionReusableView
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "showPhoto", sender: indexPath)
    }
}
