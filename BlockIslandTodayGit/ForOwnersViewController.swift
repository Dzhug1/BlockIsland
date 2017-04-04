//
//  ForOwnersViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ForOwnersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    var refresher: UIRefreshControl!
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(ForOwnersViewController.refresh), for: UIControlEvents.valueChanged)
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
                if (post.approved) ==  "no" {
                    self.posts.append(post)
                    
                    DispatchQueue.main.async {
                        self.feedCollectionView.reloadData()
                        self.refresher.endRefreshing()
                    }
                }
            }
        }, withCancel: nil)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OwnerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OwnersFeedCell", for: indexPath) as! OwnerCollectionViewCell
        
        let post = posts.reversed()[indexPath.row]
        cell.post = post
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Worth it?", message: "Just do it", preferredStyle: .alert)
        
        let post = posts.reversed()[indexPath.row]
        
        let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
            let editAlertController = UIAlertController(title: "Tell me", message: "What is wrong?", preferredStyle: .alert)
            
            let cancelUpdate = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                editAlertController.dismiss(animated: true, completion: nil)
            })
            
            let updateAction = UIAlertAction(title: "Update", style: .destructive, handler: { (_) in
                let editedText = editAlertController.textFields?[0].text
                
                FIRDatabase.database().reference().child("Posts").child("Suggested").child(post.postId!).updateChildValues(["text" : editedText!])
            })
            
            editAlertController.addTextField { (textField) in
                textField.text = post.text
            }
            
            editAlertController.addAction(cancelUpdate)
            editAlertController.addAction(updateAction)
            
            self.present(editAlertController, animated: true, completion: nil)
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
            let fromid = post.fromID
            FIRDatabase.database().reference().child("user-posts").child(fromid!).child(post.postId!).setValue(nil)
            FIRDatabase.database().reference().child("Posts").child("Suggested").child(post.postId!).setValue(nil)
        }
        
        let approveAction = UIAlertAction(title: "Approve", style: .destructive) { (_) in
            FIRDatabase.database().reference().child("Posts").child("Suggested").child(post.postId!).updateChildValues(["approved" : "yes"])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        alertController.addAction(approveAction)
        
        present(alertController, animated: true, completion:  nil)
    }
    
}
