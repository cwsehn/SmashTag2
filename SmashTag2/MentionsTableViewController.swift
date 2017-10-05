//
//  MentionsTableViewController.swift
//  SmashTag
//
//  Created by Chris William Sehnert on 9/19/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit
import Twitter


class MentionsTableViewController: UITableViewController {
    
    var tweetDetail: Twitter.Tweet? {
        didSet {
            tableView.reloadData()
            makeTableReady()
        }
    }
    
    private var mentionables = [TweetType]()
    
    
    private enum TweetType {
        case images([MediaItem])
        case hashtags([Mention])
        case urls([Mention])
        case users([Mention])
        
        func title() -> String? {
            switch self {
            case .images(let list):
                if list.isEmpty {
                    return nil
                } else { return "Images" }
                
            case .hashtags(let list):
                if list.isEmpty {
                    return nil
                } else { return "Hashtags" }
                
            case .urls(let list):
                if list.isEmpty {
                    return nil
                } else { return "URLs" }
                
            case .users(let list):
                if list.isEmpty {
                    return nil
                    
                } else { return "Users" }
            }
        }
        
        func stringify() -> [String] {
            var stringList = [String]()
            switch self {
            case .hashtags(let list), .users(let list), .urls(let list):
                for item in list {
                    stringList.append(item.keyword)
                }
                return stringList
                
            case .images(let list):
                for _ in list {
                    stringList.append("Media Item")
                }
                return stringList
            }
        }
        
        func mediafy() -> [MediaItem] {
            var tweetPics = [MediaItem]()
            switch self {
            case .images(let list):
                for item in list {
                    tweetPics.append(item)
                }
                return tweetPics
            
            default:
                return tweetPics
            }
        }
    }
    

    private func makeTableReady() {
        
        if tweetDetail != nil {
            
            let hashType = TweetType.hashtags(tweetDetail!.hashtags)
            let userType = TweetType.users(tweetDetail!.userMentions)
            let urlType = TweetType.urls(tweetDetail!.urls)
            let mediaType = TweetType.images(tweetDetail!.media)
            
            mentionables.append(mediaType)
            mentionables.append(hashType)
            mentionables.append(userType)
            mentionables.append(urlType)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionables.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionables[section].stringify().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if mentionables[indexPath.section].title() == "Images" {
            cell = tableView.dequeueReusableCell(withIdentifier: "MediaTweets", for: indexPath)
            
            if let mediaCell = cell as? MediaTweetTableViewCell {
                mediaCell.mediaTweet = mentionables[indexPath.section].mediafy()[indexPath.row]
            }
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetMentions", for: indexPath)
            let cellLabel = cell.textLabel
            cellLabel?.text = mentionables[indexPath.section].stringify()[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return mentionables[section].title()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if mentionables[indexPath.section].title() == "Images" {
            let cellWidth = tableView.frame.width
            let mediaCell = mentionables[indexPath.section].mediafy()[indexPath.row]
            let cellHeight = cellWidth/CGFloat(mediaCell.aspectRatio)
            
            return cellHeight
        }
        else {
            tableView.rowHeight = UITableViewAutomaticDimension
                return tableView.rowHeight }
    }

    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "TwitterSearch":
                if let cell = sender as? UITableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                    
                    let tweety = mentionables[indexPath.section]
                    let searchList = tweety.stringify()
                    let searchItem = searchList[indexPath.row]
                    
                    switch tweety {
                    case .hashtags, .users:
                        let seguedToMVC2 = segue.destination as? TweetTableViewController
                        seguedToMVC2?.searchText = searchItem
                        seguedToMVC2?.searchTextField.text = searchItem
                        
                    case .urls:
                        if let url = URL(string: searchItem) {
                            if UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10.0, *) {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                } else { UIApplication.shared.openURL(url) }
                            }
                        }
                        
                    default: break
                    }
                }
            case "MediaTweet":
                if let cell = sender as? MediaTweetTableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                    let slug = mentionables[indexPath.section].stringify()[indexPath.row]
                    if let imageScroller = (segue.destination.contents as? TweetImageViewController) {
                        imageScroller.tweetImage = cell.imageTweet.image
                        imageScroller.title = slug
                    }
                }
            default: break
            }
        }
    }

}






extension UIViewController {
    var contents: UIViewController {
        if let navCon = self as? UINavigationController {
            return navCon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}


