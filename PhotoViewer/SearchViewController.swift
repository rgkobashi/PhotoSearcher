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
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var topView: UIView!
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
        if !Settings.hasShownWelcome
        {
            view.bringSubviewToFront(welcomeView)
            welcomeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.hideWelcome)))
        }
        else
        {
            view.sendSubviewToBack(welcomeView)
            welcomeView.hidden = true
        }
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.showAbout)))
        navigationController?.navigationBarHidden = true
        automaticallyAdjustsScrollViewInsets = false
        (searchBar.valueForKey("searchField") as? UITextField)?.textColor = UIColor.whiteColor()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        
        fecthSearchHistory()
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
    
    @objc private func hideWelcome()
    {
        Settings.hasShownWelcome = true
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.welcomeView.alpha = 0
        }) { [unowned self] (finished) in
            self.view.sendSubviewToBack(self.welcomeView)
            self.welcomeView.hidden = true
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
    
    // MARK: - CoreData/History operations
    
    private func fecthSearchHistory()
    {
        if let history = CoreDataController.sharedInstance.fetchSearchHistory()
        {
            searchHistory.appendContentsOf(history)
            tableView.reloadData()
        }
    }
    
    private func deleteSearchHistoryItemForIndexPath(indexPath: NSIndexPath)
    {
        Components.displayAlertWithTitle(nil, message: "Are you sure?", buttonTitle: "Cancel", buttonHandler: nil, destructiveTitle: "Delete", destructiveHandler: { [unowned self] in
            let searchHistoryItem = self.searchHistory[indexPath.row]
            CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
            self.searchHistory.removeAtIndex(indexPath.row)
            self.tableView.reloadData()
        })
    }
    
    private func selectSearchHistoryItemForIndexPath(indexPath: NSIndexPath)
    {
        let searchHistoryItem = searchHistory[indexPath.row]
        let searchTerm = searchHistoryItem.searchTerm!
        
        CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
        searchHistory.removeAtIndex(indexPath.row)
        
        showSearchResultsForSearchTerm(searchTerm)
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
    
    @objc private func showAbout()
    {
        performSegueWithIdentifier("showAbout", sender: nil)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath) as! HistoryTableViewCell
        cell.label.text = searchHistory[indexPath.row].searchTerm
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
            deleteSearchHistoryItemForIndexPath(indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectSearchHistoryItemForIndexPath(indexPath)
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
        searchBar.text = ""
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
