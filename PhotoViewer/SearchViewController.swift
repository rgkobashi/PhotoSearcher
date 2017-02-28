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
    
    private var searchHistory = [CD_SearchHistoryItem]()
    
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
        
        if let history = CoreDataController.sharedInstance.fetchSearchHistory()
        {
            searchHistory.appendContentsOf(history)
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
            return encoded.lowercaseString
        }
        else
        {
            return words.first!.lowercaseString
        }
    }
    
    // MARK: - Navigation
    
    private func showSearchResultsForSearchTerm(searchTerm: String)
    {
        let searchHistoryItem = CoreDataController.sharedInstance.saveSearchHistoryItem(searchTerm, timeStamp: NSDate().timeIntervalSince1970)
        searchBar.text = ""
        searchBar.endEditing(true)
        searchHistory.insert(searchHistoryItem, atIndex: 0)
        performSegueWithIdentifier("showSearchResults", sender: searchHistoryItem.searchTerm)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showSearchResults"
        {
            let searchResultsVC = segue.destinationViewController as! SearchResultsViewController
            searchResultsVC.searchTerm = sender as! String
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate
{
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchHistory.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath)
        cell.textLabel?.text = searchHistory[indexPath.row].searchTerm
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            let searchHistoryItem = searchHistory[indexPath.row]
            CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
            searchHistory.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let searchHistoryItem = searchHistory[indexPath.row]
        let searchTerm = searchHistoryItem.searchTerm!
        
        CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
        searchHistory.removeAtIndex(indexPath.row)
        
        showSearchResultsForSearchTerm(searchTerm)
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
            showSearchResultsForSearchTerm(formatSearchTerm(text))
        }
    }
}
