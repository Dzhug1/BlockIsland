//
//  LoginViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/26/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var rootRef = FIRDatabase.database().reference()
    
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func logInTapped(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if (error == nil) {
                let user = FIRAuth.auth()?.currentUser
                guard let uid = user?.uid else {
                    return
                }
                _ = self.rootRef.child("users").child(uid).child("status").observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
                    if let status = snapshot.value as? String {
                        if status == "god"{
                            self.performSegue(withIdentifier: "ForOwnersSeque", sender: nil)
                        } else if status == "user" {
                            self.performSegue(withIdentifier: "HomeViewSeque", sender: nil)
                        } else if status == "businessowner" {
                            self.performSegue(withIdentifier: "ForBusinessesSeque", sender: nil)
                        }
                    }
                })
            } else {
                self.errorMessage.text = error?.localizedDescription
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
