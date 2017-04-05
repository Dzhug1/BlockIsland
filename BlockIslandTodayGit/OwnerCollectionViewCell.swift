//
//  OwnerCollectionViewCell.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 4/3/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import Firebase

class OwnerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postBusinessName: UILabel!
    @IBOutlet weak var postText: UITextView!
    @IBOutlet weak var businessImage: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    var imageArray = [UIImage]()
    
    var post: Post? {
        didSet{
            imageArray.removeAll()
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
                            }
                        }
                    }, withCancel: nil)
                }
                
                if let postImageURL1 = post?.postImage1 {
                    AppendTheImmageArray(postImageURL: postImageURL1)
                    if let postImageURL2 = post?.postImage2{
                        AppendTheImmageArray(postImageURL: postImageURL2)
                        if let postImageURL3 = post?.postImage3{
                            AppendTheImmageArray(postImageURL: postImageURL3)
                            if let postImageURL4 = post?.postImage4{
                                AppendTheImmageArray(postImageURL: postImageURL4)
                            }
                        }
                    }
                }
                
                for i in 0..<imageArray.count{
                    let imageView = UIImageView()
                    imageView.image = imageArray[i]
                    let xPosition = imageScrollView.frame.width * CGFloat(i)
                    imageView.frame = CGRect(x: xPosition, y: 0, width: imageScrollView.frame.width, height: imageScrollView.frame.height)
                    imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i + 1)
                    imageScrollView.addSubview(imageView)
                }
            }
        }
    }
    
    func AppendTheImmageArray(postImageURL: String) {
        let url = NSURL(string: postImageURL)
        if let cachedPostImage = imageCache.object(forKey: postImageURL as AnyObject) {
            imageArray.append(cachedPostImage as! UIImage)
            return
        }
        self.GetDatafromURL(url: url! as URL, completion:
            { (data, response, error) in
            if error != nil {
                print (error!)
            }
                DispatchQueue.main.async {
                    let downloadedImage = UIImage(data: data!)
                    imageCache.setObject(downloadedImage!, forKey: postImageURL as AnyObject)
                    self.imageArray.append(downloadedImage!)
                }
        })
    }
    
    
    func GetDatafromURL(url: URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?,  _ error: Error?) -> Void))
    {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            completion (data , response, error)
            }.resume()
    }
    
}

