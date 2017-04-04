//
//  UserProfileViewController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {

    @IBOutlet weak var logOutButtonOutlet: UIButton!
    @IBOutlet weak var signInButtonOutlet: UIButton!
    @IBAction func logOutDidTapped(_ sender: UIButton) {
        try! FIRAuth.auth()?.signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                print("user is logged in")
                self.signInButtonOutlet.isHidden = true
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

}
