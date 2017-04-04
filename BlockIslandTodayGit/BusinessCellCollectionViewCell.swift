//
//  BusinessCellCollectionViewCell.swift
//  BlockIslandTodayGit
//
//  Created by Roman Dzhugan on 4/4/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase

class BusinessCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postBusinessName: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var approvedImage: UIImageView!
    
    var post: Post? {
        didSet{
            approvedImage.isHidden = true
            let currenttime = NSNumber(value: Int(NSDate().timeIntervalSince1970))
            if (post?.timestamp?.intValue)! < currenttime.intValue {
                postText.text = post?.text
                if let fromID = post?.fromID {
                    let ref = FIRDatabase.database().reference().child("users").child(fromID)
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject] {
                            self.postBusinessName.text = dictionary["name"] as? String
                            if let seconds = self.post?.timestamp?.doubleValue{
                                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "hh:mm:ss a"
                                self.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
                                if self.post?.approved == "yes" {
                                    self.approvedImage.isHidden = false
                                }
                            }
                        }
                    }, withCancel: nil)
                }
                if let postImageURL = post?.postImage {
                    if let cachedPostImage = imageCache.object(forKey: postImageURL as AnyObject) {
                        postImage.image = cachedPostImage as? UIImage
                        return
                    }
                    let url = NSURL(string: postImageURL)
                    self.GetDatafromURL(url: url! as URL, completion: { (data, response, error) in
                        if error != nil {
                            print (error!)
                        }
                        if let downloadedImage = UIImage(data: data!) {
                            imageCache.setObject(downloadedImage, forKey: postImageURL as AnyObject)
                            self.postImage.image = downloadedImage
                        }
                    })
                    
                }
            }
            
        }
    }
    
    
    func GetDatafromURL(url: URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?,  _ error: Error?) -> Void))
    {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            completion (data , response, error)
            }.resume()
    }
    
}
