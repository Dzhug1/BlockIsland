//
//  FeedUserViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class FeedUserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    var refresher: UIRefreshControl!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(FeedUserViewController.refresh), for: UIControlEvents.valueChanged)
        feedCollectionView.addSubview(refresher)
    }
    
    func refresh() {
        posts.removeAll()
        observePosts()
    }
    
    func observePosts() {
        let ref = FIRDatabase.database().reference().child("Posts").child("Suggested")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let post = Post()
                post.setValuesForKeys(dictionary)
                if post.approved == "yes"{
                    let currenttime = NSNumber(value: Int(NSDate().timeIntervalSince1970))
                    if (post.timestamp?.intValue)! < currenttime.intValue {
                        self.posts.append(post)
        
                        DispatchQueue.main.async {
                            self.feedCollectionView.reloadData()
                            self.refresher.endRefreshing()
                        }
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FeedUserCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as! FeedUserCollectionViewCell
        
        let post = posts.reversed()[indexPath.row]
        cell.post = post
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print ("Cell \(indexPath.row) selected")
    }

}
