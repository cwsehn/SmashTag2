//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Chris William Sehnert on 9/12/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
        
    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            // print(tweets)
        }
    }
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
            last100.latestSearch = searchText
        }
    }
    
    func insertTweets (_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    
    
    private var last100 = ListMaker()
    
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query, count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        
                        self?.insertTweets(newTweets)
                        
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    
    @IBOutlet weak var searchTextField: UITextField! {
        
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Updates...\(tweets.count-section)"
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if let id = segue.identifier {
            switch id {
            case "Mention":
                if let cell = sender as? TweetTableViewCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? MentionsTableViewController {
                    let userScreenName = tweets[indexPath.section][indexPath.row].user.screenName
                    seguedToMVC.navigationItem.title = "@\(userScreenName)"
                    seguedToMVC.tweetDetail = tweets[indexPath.section][indexPath.row]
                }                
            default: break
            }
        }
    }
}



struct ListMaker {
    
    var defaults = UserDefaults.standard
    
    var latestSearch: String? {
        didSet {
            updateList()
        }
    }
    
    private func updateList() {
        var searchList: Array<String> = defaults.object(forKey:"last100Searches") as? [String] ?? [String]()
        
        if let searchString = latestSearch?.lowercased() {
            if searchList.contains(searchString) {
                let oldIndex = searchList.index(of: searchString)
                searchList.remove(at: oldIndex!)
            }
            searchList.insert(searchString, at: 0)
            if searchList.endIndex == 101 {
                searchList.remove(at: 100)
            }
        }
        defaults.set(searchList, forKey: "last100Searches")
    }
}




















