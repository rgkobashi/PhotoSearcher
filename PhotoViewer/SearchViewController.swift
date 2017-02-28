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
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var flickrButton: UIButton!
    
    fileprivate var constraintValue:CGFloat = 0.0
    fileprivate var keyboardHeight:CGFloat = 0.0
    fileprivate var searchHistory = [CD_SearchHistoryItem]()
    
    deinit
    {
        print("deinit SearchViewController")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if !Settings.hasShownWelcome
        {
            view.bringSubview(toFront: welcomeView)
            welcomeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.hideWelcome)))
        }
        else
        {
            view.sendSubview(toBack: welcomeView)
            welcomeView.isHidden = true
        }
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SearchViewController.showAbout)))
        navigationController?.isNavigationBarHidden = true
        automaticallyAdjustsScrollViewInsets = false
        (searchBar.value(forKey: "searchField") as? UITextField)?.textColor = UIColor.white
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        fecthSearchHistory()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func buttonTapped(_ sender: UIButton)
    {
        if sender == instagramButton
        {
            Utilities.openURLWithString(kAppURLInstagram)
        }
        else if sender == flickrButton
        {
            Utilities.openURLWithString(kAppURLFlickr)
        }
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification)
    {
        if let userInfo = notification.userInfo
        {
            if let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue
            {
                let keyboardRec = value.cgRectValue
                keyboardHeight = keyboardRec.height
                constraintValue = tableViewBottomConstraint.constant
                tableViewBottomConstraint.constant = keyboardHeight
            }
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification)
    {
        if keyboardHeight != 0.0
        {
            tableViewBottomConstraint.constant = constraintValue
            keyboardHeight = 0.0
            constraintValue = 0.0
        }
    }
    
    @objc fileprivate func hideWelcome()
    {
        Settings.hasShownWelcome = true
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.welcomeView.alpha = 0
        }, completion: { [unowned self] (finished) in
            self.view.sendSubview(toBack: self.welcomeView)
            self.welcomeView.isHidden = true
        }) 
    }
    
    fileprivate func formatSearchTerm(_ searchTerm: String) -> String
    {
        let words = searchTerm.components(separatedBy: " ")
        if let encoded = words.first!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        {
            return encoded.lowercased()
        }
        else
        {
            return words.first!.lowercased()
        }
    }
    
    // MARK: - CoreData/History operations
    
    fileprivate func fecthSearchHistory()
    {
        if let history = CoreDataController.sharedInstance.fetchSearchHistory()
        {
            searchHistory.append(contentsOf: history)
            tableView.reloadData()
        }
    }
    
    fileprivate func deleteSearchHistoryItemForIndexPath(_ indexPath: IndexPath)
    {
        Utilities.displayAlertWithTitle(nil, message: "Are you sure?", buttonTitle: "Cancel", buttonHandler: nil, destructiveTitle: "Delete", destructiveHandler: { [unowned self] in
            let searchHistoryItem = self.searchHistory[indexPath.row]
            CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
            self.searchHistory.remove(at: indexPath.row)
            self.tableView.reloadData()
        })
    }
    
    fileprivate func selectSearchHistoryItemForIndexPath(_ indexPath: IndexPath)
    {
        let searchHistoryItem = searchHistory[indexPath.row]
        let searchTerm = searchHistoryItem.searchTerm!
        
        CoreDataController.sharedInstance.deleteSearchHistoryItem(searchHistoryItem)
        searchHistory.remove(at: indexPath.row)
        
        showSearchResultsForSearchTerm(searchTerm)
    }
    
    // MARK: - Navigation
    
    fileprivate func showSearchResultsForSearchTerm(_ searchTerm: String)
    {
        let searchHistoryItem = CoreDataController.sharedInstance.saveSearchHistoryItemWithSearchTerm(searchTerm, timeStamp: Date().timeIntervalSince1970)
        searchBar.text = ""
        searchBar.endEditing(true)
        searchHistory.insert(searchHistoryItem, at: 0)
        performSegue(withIdentifier: "showSearchResults", sender: searchHistoryItem.searchTerm)
    }
    
    @objc fileprivate func showAbout()
    {
        performSegue(withIdentifier: "showAbout", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showSearchResults"
        {
            let searchResultsVC = segue.destination as! SearchResultsViewController
            searchResultsVC.searchTerm = sender as! String
        }
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate
{
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        cell.label.text = searchHistory[indexPath.row].searchTerm
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete)
        {
            deleteSearchHistoryItemForIndexPath(indexPath)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectSearchHistoryItemForIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    {
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = UIColor(hex: kColorYellow)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    {
        let cell  = tableView.cellForRow(at: indexPath)
        cell!.contentView.backgroundColor = UIColor.clear
    }
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if let text = searchBar.text, text != ""
        {
            showSearchResultsForSearchTerm(formatSearchTerm(text))
        }
    }
}
