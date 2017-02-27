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
    
    private var history = [String]()
    
    deinit
    {
        print("deinit SearchViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        history.appendContentsOf(CoreDataController.sharedInstance.fetchSearchHistory())
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        return history.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("historyCell", forIndexPath: indexPath)
        cell.textLabel?.text = history[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
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
            let textFormatted = formatSearchTerm(text)
            CoreDataController.sharedInstance.saveSearchTerm(textFormatted, timeStamp: NSDate().timeIntervalSince1970)
            history.insert(textFormatted, atIndex: 0)
            performSegueWithIdentifier("showSearchResults", sender: textFormatted)
        }
    }
}
