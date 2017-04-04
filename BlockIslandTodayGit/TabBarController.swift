//
//  TabBarController.swift
//  BlockIslandToday
//
//  Created by Roman Dzhugan on 3/28/17.
//  Copyright © 2017 Roman Dzhugan. All rights reserved.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                print("user is logged in")
            } else {
                self.performSegue(withIdentifier: "LogInSeque", sender: nil)
                print("no users is logged in")
            }
        }
    }

    

}
