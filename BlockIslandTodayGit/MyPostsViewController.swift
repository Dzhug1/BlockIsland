//
//  MyPostsViewController.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/4/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyPostsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var feedCollectionView: UICollectionView!
    
    let user = FIRAuth.auth()?.currentUser?.uid
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
                if (post.fromID) ==  self.user {
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
        let cell: BusinessCellCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusinessCell", for: indexPath) as! BusinessCellCollectionViewCell
        
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(editAction)
        
        present(alertController, animated: true, completion:  nil)
    }
    
}
