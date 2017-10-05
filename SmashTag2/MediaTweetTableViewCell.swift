//
//  MediaTweetTableViewCell.swift
//  SmashTag2
//
//  Created by Chris William Sehnert on 9/25/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit
import Twitter

class MediaTweetTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var imageTweet: UIImageView!
    
    
    var mediaTweet: Twitter.MediaItem? { didSet{ updateUI() } }
    
    
    private func updateUI() {
        imageTweet.image = nil
    
        if let mediaItemURL = mediaTweet?.url {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: mediaItemURL)
                if let imageData = urlContents, mediaItemURL == self?.mediaTweet?.url {
                    DispatchQueue.main.async {
                        self?.imageTweet.image = UIImage(data: imageData)
                    }
                }
            }
        } else { imageTweet.image = nil }
    
    }

}
