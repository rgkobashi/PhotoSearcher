//
//  SearchViewController.swift
//  PhotoViewer
//
//  Created by Rogelio Martinez Kobashi on 2/27/17.
//  Copyright © 2017 Rogelio Martinez Kobashi. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    private var keyboardHeight:CGFloat = 0.0
    
    private var history = [CD_SearchTerm]()
    
    deinit
    {
        print("deinit SearchViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        automaticallyAdjustsScrollViewInsets = false
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        if let fetchedHistory = CoreDataController.sharedInstance.fetchSearchHistory()
        {
            history.appendContentsOf(fetchedHistory)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func keyboardWillShow(notification: NSNotification)
    {
        if let userInfo = notification.userInfo
        {
            if let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            {
                let keyboardRec = value.CGRectValue()
                keyboardHeight = keyboardRec.height
                tableViewBottomConstraint.constant += keyboardHeight
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification)
    {
        if keyboardHeight != 0.0
        {
            tableViewBottomConstraint.constant -= keyboardHeight
            keyboardHeight = 0.0
        }
    }
    
    private func formatSearchTerm(searchTerm: String) -> String
    {
        let words = searchTerm.componentsSeparatedByString(" ")
        if let encoded = words.first!.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        {
            return encoded
        }
        else
        {
            return words.first!
        }
    }
    
    // MARK: - Navigation
    
    private func showSearchResults(searchTerm: CD_SearchTerm)
    {
        searchBar.text = ""
        searchBar.endEditing(true)
        history.insert(searchTerm, atIndex: 0)
        performSegueWithIdentifier("showSearchResults", sender: searchTerm)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showSearchResults"
        {
            let searchResultsVC = segue.destinationViewController as! SearchResultsViewController
            searchResultsVC.stringSearchTerm = (sender as! CD_SearchTerm).term // TODO rename searchName on SearchResultsViewController
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate
{
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return history.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath)
        cell.textLabel?.text = history[indexPath.row].term
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let searchTerm = history[indexPath.row]
        let stringSearchTerm = searchTerm.term!
        
        CoreDataController.sharedInstance.deleteSearchTerm(searchTerm)
        history.removeAtIndex(indexPath.row)
        
        if let newSearchTerm = CoreDataController.sharedInstance.saveSearchTerm(formatSearchTerm(stringSearchTerm), timeStamp: NSDate().timeIntervalSince1970) // TODO move here el termino en minusculas
        {
            showSearchResults(newSearchTerm)
        }
    }
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        if let text = searchBar.text where text != ""
        {
            if let searchTerm = CoreDataController.sharedInstance.saveSearchTerm(formatSearchTerm(text), timeStamp: NSDate().timeIntervalSince1970) // TODO move here el termino en minusculas
            {
                showSearchResults(searchTerm)
            }
            // TODO do something for el else
        }
    }
}
