//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Chris William Sehnert on 9/12/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
  
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private func updateUI() {
        
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImgURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: profileImgURL)
                if let imageData = urlContents, profileImgURL == self?.tweet?.user.profileImageURL {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView.image = nil
        }
        
        
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
        
        
        if let attributalbleText = tweet?.text {
            let coloredText = NSMutableAttributedString(string: attributalbleText)
            
            if let coloredHash = tweet?.hashtags {
                for hashTag in coloredHash {
                    coloredText.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: hashTag.nsrange)
                }
            }
            if let coloredURLs = tweet?.urls {
                for url in coloredURLs {
                    coloredText.addAttribute(NSForegroundColorAttributeName, value: UIColor.cyan, range: url.nsrange)
                }
            }
            if let coloredMentions = tweet?.userMentions {
                for mention in coloredMentions {
                    coloredText.addAttribute(NSForegroundColorAttributeName, value: UIColor.brown, range: mention.nsrange)
                }
            }
            tweetTextLabel?.attributedText = coloredText
        } else {
            tweetTextLabel?.text = nil
        }
        
    }
    
}



