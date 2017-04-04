//
//  UserProfileViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UserProfileViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logOutButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    
    
    @IBAction func logOutDidTapped(_ sender: UIButton) {
        try! FIRAuth.auth()?.signOut()
        profileImage.image = UIImage(named: "Profile")
        userNameLabel.text = ""
        emailLabel.text = "Your email can be here"
    }
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                print("user is logged in")
                self.signInButtonOutlet.isHidden = true
                let userId = FIRAuth.auth()?.currentUser?.uid
                let ref = FIRDatabase.database().reference().child("users").child(userId!)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: String] {
                        let user = User()
                        user.setValuesForKeys(dictionary)
                        self.userNameLabel.text = user.name
                        self.emailLabel.text = user.email
                        let profileImageURL = user.profileImage
                        if let cachedPostImage = imageCache.object(forKey: profileImageURL as AnyObject) {
                            self.profileImage.image = cachedPostImage as? UIImage
                            return
                        }
                        let url = NSURL(string: profileImageURL!)
                        self.GetDatafromURL(url: url! as URL, completion: { (data, response, error) in
                            if error != nil {
                                print (error!)
                            }
                            if let downloadedImage = UIImage(data: data!) {
                                imageCache.setObject(downloadedImage, forKey: profileImageURL as AnyObject)
                                self.profileImage.image = downloadedImage
                            }
                        })
                    }
                })
            } else {
                self.logOutButtonOutlet.isHidden = true
                self.signInButtonOutlet.isHidden = false
                print("no users is logged in")
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LogInSeque", sender: nil)
    }
    
    func GetDatafromURL(url: URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?,  _ error: Error?) -> Void))
    {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            completion (data , response, error)
            }.resume()
    }

}
