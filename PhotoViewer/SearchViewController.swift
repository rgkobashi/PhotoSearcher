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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        searchBar.delegate = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
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

extension SearchViewController: UITableViewDelegate
{
    
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
        performSegueWithIdentifier("showSearchResults", sender: searchBar.text)
    }
}
