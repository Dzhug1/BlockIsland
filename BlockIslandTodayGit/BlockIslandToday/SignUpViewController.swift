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

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorMessage: UILabel!

    
    let imagePicker = UIImagePickerController()
    var selectedPhoto: UIImage!
    var databaseRef = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.isEnabled = false

        let tap = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.selectPhoto(tap:)))
        tap.numberOfTapsRequired = 1
        profileImage.addGestureRecognizer(tap)
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
    }

    func selectPhoto(tap: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.imagePicker.sourceType = .camera
        } else {
            self.imagePicker.sourceType = .photoLibrary
        }
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancelDidTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpDidTapped(_ sender: Any) {
        signUpButton.isEnabled = false
        
        FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if(error != nil) {
                self.errorMessage.text = error!.localizedDescription
            } else {
                self.errorMessage.text = "Registered succesfully"
                
                FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    if error == nil {
                        self.databaseRef.child("users").child((user?.uid)!).child("email").setValue(self.emailTextField.text)
                        self.databaseRef.child("users").child((user?.uid)!).child("name").setValue(self.usernameTextField.text)
                        self.databaseRef.child("users").child((user?.uid)!).child("status").setValue("user")
                        self.performSegue(withIdentifier: "HomeViewSeque", sender: nil)
                    }
                })
            }
        })
    }
    
    @IBAction func textDidChanged(_ sender: UITextField) {
        if((usernameTextField.text?.characters.count)!>0 && (emailTextField.text?.characters.count)!>0 && (passwordTextField.text?.characters.count)!>0)
        {
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // imagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.profileImage.image = selectedPhoto
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
