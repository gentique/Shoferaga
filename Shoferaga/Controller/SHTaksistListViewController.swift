//
//  SHTaksistViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SHTaksistListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRequests()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loadRequests(){
        Database.database().reference().child("Request").observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
        }
    }
    


}
