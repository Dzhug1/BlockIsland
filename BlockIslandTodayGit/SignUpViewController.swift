//
//  SignUpViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/26/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!

    var databaseRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
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
        profileImage.image = selectedPhoto
        
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
    
    @IBAction func cancelDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpDidTapped(_ sender: Any) {
        FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if(error != nil) {
                self.errorMessage.text = error?.localizedDescription
            } else {
                self.errorMessage.text = "Registered succesfully. Entering..."
                
                FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    if error == nil {
                        self.databaseRef.child("users").child((user?.uid)!).child("email").setValue(self.emailTextField.text)
                        self.databaseRef.child("users").child((user?.uid)!).child("name").setValue(self.usernameTextField.text)
                        self.databaseRef.child("users").child((user?.uid)!).child("status").setValue("user")
                        if self.profileImage.image != nil {
                            let imageName = UUID().uuidString
                            let storageRef = FIRStorage.storage().reference().child("Profiles").child("\(imageName).jpg")
                            if let uploadData = UIImageJPEGRepresentation(self.profileImage.image!, 0.2){
                                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                    if error != nil {
                                        print (error as Any)
                                        return
                                    } else if let postImageURL = metadata?.downloadURL()?.absoluteString {
                                        self.databaseRef.child("users").child((user?.uid)!).child("profileImage").setValue(postImageURL)
                                        self.performSegue(withIdentifier: "HomeViewSeque", sender: nil)
                                    }
                                })
                            }
                        }
                        self.performSegue(withIdentifier: "HomeViewSeque", sender: nil)
                    }
                })
            }
        })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
