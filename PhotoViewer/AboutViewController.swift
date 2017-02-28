//
//  AboutViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 3/1/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController
{
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var webButton: UIButton!
    @IBOutlet weak var linkedInButton: UIButton!
    @IBOutlet weak var githubButton: UIButton!
    
    deinit
    {
        print("deinit AboutViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(AboutViewController.close))
        swipeGestureRecognizer.direction = .Down
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        swipeGestureRecognizer.enabled = true
        swipeGestureRecognizer.cancelsTouchesInView = true
        swipeGestureRecognizer.delaysTouchesEnded = true
        view.addGestureRecognizer(swipeGestureRecognizer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AboutViewController.close)))
    }
    
    @IBAction func buttonTapped(sender: UIButton)
    {
        switch sender {
        case emailButton:
            Utilities.openURLWithString(kEmail)
        case webButton:
            Utilities.openURLWithString(kURLWebsite)
        case linkedInButton:
            Utilities.openURLWithString(kURLLinkedIn)
        case githubButton:
            Utilities.openURLWithString(kURLGithub)
        default:
            break
        }
    }
    
    @objc private func close()
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
