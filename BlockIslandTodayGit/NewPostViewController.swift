//
//  NewPostViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class NewPostViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newPostTextView: UITextView!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var postDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    @IBAction func imageIsTapped(_ sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        newImageView.image = selectedPhoto
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        /* 
         MARK: clear the text on editting
         */
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapPostButton(_ sender: UIButton) {
        
        let user = FIRAuth.auth()?.currentUser
        guard let uid = user?.uid else {
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("Posts").child("\(imageName).jpg")
        if newImageView.image != nil && newPostTextView.text.characters.count>0 {
            if let uploadData = UIImageJPEGRepresentation(newImageView.image!, 0.2) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print (error as Any)
                        return
                    } else if let postImageURL = metadata?.downloadURL()?.absoluteString {
                        let postDate = self.postDatePicker.date.timeIntervalSince1970
                        let timestamp = NSNumber(value: Int(postDate))
                        let refData = FIRDatabase.database().reference(fromURL: "https://blockislandtoday-302d7.firebaseio.com/")
                        let userReference = refData.child("Posts").child("Suggested").childByAutoId()
                        let postId = userReference.key
                        let value = ["postId": postId, "postImage": postImageURL, "text": self.newPostTextView.text!, "fromID": uid, "timestamp": timestamp, "approved": "no"] as [String : Any]
                        userReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print(err as Any)
                                return
                            }
                            
                            let userPostRef = FIRDatabase.database().reference().child("user-posts").child(uid)
                            
                            let postID = postId
                            userPostRef.updateChildValues([postID: 1])
                            
                            self.createAlert(title: "Posting", message: "Your immage has been posted")
                            
                        })
                    }
                    
                })
            }
        } else {
            createAlert(title: "Posting", message: "Please insert a post data")
        }
        
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
