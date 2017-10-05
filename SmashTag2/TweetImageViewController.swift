//
//  TweetImageViewController.swift
//  SmashTag2
//
//  Created by Chris William Sehnert on 9/29/17.
//  Copyright © 2017 InSehnDesigns. All rights reserved.
//

import UIKit
import Twitter

class TweetImageViewController: UIViewController {

    var tweetImage: UIImage?
    
    fileprivate var imageView = UIImageView()
    
    @IBOutlet weak var scrollView: UIScrollView!
        {
        didSet {
            // print("scrollView is set")
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.05
            scrollView.maximumZoomScale = 10.0
        }
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prepareOptimalImageRect()
    }
    
    private func prepareOptimalImageRect() {
        
        imageView.image = tweetImage
        imageView.sizeToFit()
        
        var tweetImageAspect: CGFloat = 1
        let viewAspect = scrollView.bounds.maxX / (scrollView.bounds.maxY)
        var optimalRect: CGRect = CGRect()
        
        if imageView.image != nil {
            tweetImageAspect = imageView.bounds.width / imageView.bounds.height
        }
        
        if viewAspect > tweetImageAspect {
            optimalRect = CGRect(x: 0, y: -100, width: imageView.bounds.width, height: imageView.bounds.width / viewAspect)
        } else {
            optimalRect = CGRect(x: 0, y: -100, width: imageView.bounds.height * viewAspect, height: imageView.bounds.height)
        }
        
        scrollView.contentSize = imageView.frame.size
        scrollView.addSubview(imageView)
        scrollView.zoom(to: optimalRect, animated: true)
        
    }
}


extension TweetImageViewController: UIScrollViewDelegate {
    /*
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect: CGRect = imageView.convert(scrollView.bounds, from: scrollView)
        
        print("visibleRectorigin: \(visibleRect.origin)")
    }
 
    */
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
 
}





