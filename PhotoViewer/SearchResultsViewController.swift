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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var searchTerm: String!
    
    deinit
    {
        print("deinit SearchResultsViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        titleLabel.text = ""
        subtitleLabel.text = ""
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
        SessionManager.sharedInstance.start(service, suceedHandler: { (response) in
            Loader.dismiss()
            print("response = \(response)")
        }) { (error) in
            Loader.dismiss()
            print("error = \(error)")
            // TODO handler the errors
        }
    }
}
