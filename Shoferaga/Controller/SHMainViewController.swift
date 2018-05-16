//
//  ViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/16/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit

class SHMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        // nese du me u bo shum perfeksionist ateher muna me e thirr qita ma posht me protocols and delegate
        if !(navigationController?.isNavigationBarHidden)!{
            self.navigationController?.setNavigationBarHidden(true, animated: true)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func buttonsPressed(_ sender: Any) {

        self.navigationController?.setNavigationBarHidden(false, animated: false)

    }
}

