//
//  TabBarController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TabBarController: UITabBarController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                let user = FIRAuth.auth()?.currentUser
                guard let uid = user?.uid else {
                    return
                }
                let rootRef = FIRDatabase.database().reference()
                    rootRef.child("users").child(uid).child("status").observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
                    if let status = snapshot.value as? String {
                        if status == "god"{
                            self.performSegue(withIdentifier: "ForOwnersSeque", sender: nil)
                        } else if status == "businessowner" {
                            self.performSegue(withIdentifier: "ForBusinessesSeque", sender: nil)
                        }
                    }
                })
            } else {
                print("no users is logged in")
            }
        }
    }
}
