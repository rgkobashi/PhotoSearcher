//
//  WelcomeViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/28/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController
{
    
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var searcherLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WelcomeViewController.showSearch)))
    }

    func showSearch()
    {
        performSegueWithIdentifier("showSearch", sender: nil)
    }
}
