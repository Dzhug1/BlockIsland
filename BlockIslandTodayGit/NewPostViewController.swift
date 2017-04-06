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
    
    var imageArray = [UIImage]()

    @IBOutlet weak var newPostTextView: UITextView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var cancel1: UIButton!
    @IBOutlet weak var cancel2: UIButton!
    @IBOutlet weak var cancel3: UIButton!
    @IBOutlet weak var cancel4: UIButton!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var postDatePicker: UIDatePicker!
    
    @IBAction func printTapped(_ sender: UIButton) {
        print(imageArray.count)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancel1.isHidden = true
        cancel2.isHidden = true
        cancel3.isHidden = true
        cancel4.isHidden = true
 
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancel1Tapped(_ sender: UIButton) {
        image1.image = nil
        imageArray.removeLast()
        button1.isHidden = false
        cancel1.isHidden = true
    }
    
    @IBAction func cancel2Tapped(_ sender: UIButton) {
        image2.image = nil
        imageArray.removeLast()
        button2.isHidden = false
        cancel2.isHidden = true
        cancel1.isHidden = false
    }
    
    @IBAction func cancel3Tapped(_ sender: UIButton) {
        image3.image = nil
        imageArray.removeLast()
        button3.isHidden = false
        cancel3.isHidden = true
        cancel2.isHidden = false
    }
    
    @IBAction func cancel4Tapped(_ sender: UIButton) {
        image4.image = nil
        imageArray.removeLast()
        button4.isHidden = false
        cancel4.isHidden = true
        cancel3.isHidden = false
        addImageButton.isEnabled = true
    }
    
    
    @IBAction func imageIsTapped(_ sender: AnyObject) {
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage
        if image1.image == nil {
            image1.image = selectedPhoto
            imageArray.append(image1.image!)
            button1.isHidden = true
            cancel1.isHidden = false
            dismiss(animated: true, completion: nil)
        } else
        if image2.image == nil {
            image2.image = selectedPhoto
            imageArray.append(image2.image!)
            button2.isHidden = true
            cancel2.isHidden = false
            cancel1.isHidden = true
            dismiss(animated: true, completion: nil)
        } else
        if image3.image == nil {
            image3.image = selectedPhoto
            imageArray.append(image3.image!)
            button3.isHidden = true
            cancel3.isHidden = false
            cancel2.isHidden = true
            dismiss(animated: true, completion: nil)
        } else
        if image4.image == nil {
            image4.image = selectedPhoto
            imageArray.append(image4.image!)
            button4.isHidden = true
            cancel4.isHidden = false
            cancel3.isHidden = true
            dismiss(animated: true, completion: nil)
            addImageButton.isEnabled = false
        }
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
        let refData = FIRDatabase.database().reference(fromURL: "https://blockislandtoday-302d7.firebaseio.com/")
        let postReference = refData.child("Posts").child("Suggested").childByAutoId()
        let postId = postReference.key
        let postUID = UUID().uuidString
        if imageArray.count != 0 && newPostTextView.text.characters.count>0 {
            for i in 0..<imageArray.count{
                let imageName = UUID().uuidString
                let storageRef = FIRStorage.storage().reference().child("Posts").child(postUID).child("\(imageName).jpg")
                if let uploadData = UIImageJPEGRepresentation(imageArray[i], 0.2) {
                    storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                        if error != nil {
                            print (error as Any)
                            return
                        } else if let postImageURL = metadata?.downloadURL()?.absoluteString {
                            let postDate = self.postDatePicker.date.timeIntervalSince1970
                            let timestamp = NSNumber(value: Int(postDate))
                            let value = ["postId": postId, "postImage\(i + 1)": postImageURL, "text": self.newPostTextView.text!, "fromID": uid, "timestamp": timestamp, "approved": "no"] as [String : Any]
                            postReference.updateChildValues(value, withCompletionBlock: { (err, ref) in
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
