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
    
    var searchTerm: String!
    
    deinit
    {
        print("deinit SearchResultsViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchTermLabel.text = ""
        postsCountLabel.text = ""
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
                self.searchTermLabel.text = "#\(result.name.lowercaseString)"
                self.updatePostsCountLabel(result.count)
                print("result.topPosts = \(result.topPosts)")
                print("result.mostRecent = \(result.mostRecent)")
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
}
