//
//  SHLogInViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SHLogInViewController: UIViewController {
    
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func logInButton(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Logging in...")
        Auth.auth().signIn(withEmail: userName.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil{
                SVProgressHUD.setStatus("Error")
                print(error!.localizedDescription)
                SVProgressHUD.dismiss(withDelay: 2)
                
            }
            else{
                SVProgressHUD.setStatus("Success")
                print(Auth.auth().currentUser!.uid)
                self.getUserInfo()
                // self.performSegue(withIdentifier: SHUdhetareViewController.segueName, sender: self)
            }
        }
    }

    func getUserInfo(){
        SVProgressHUD.setStatus("Getting info..")
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        ref.child("Users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            let isWorker = snapshotValue["Worker"] as! Bool
            
            if isWorker{
                print("IS worker true")
                print(isWorker)
                SVProgressHUD.setStatus("Success")
                SVProgressHUD.dismiss(withDelay: 2, completion: {
                    self.performSegue(withIdentifier: SHTaksistListViewController.segueName, sender: self)
                })
            }else{
                let email = snapshotValue["Email"]
                let money = snapshotValue["Money"]
                let name = snapshotValue["Name"]
                let surname = snapshotValue["Surname"]
                let phoneNumber = snapshotValue["Phone Number"]
                let lat = snapshotValue["lat"]
                let lon = snapshotValue["lon"]
                
                let user = Udhetare()
                user.email = email as! String
                user.lat = lat as! Double
                user.lon = lon as! Double
                user.money = money as! Double
                user.name = name as! String
                user.phoneNumber = phoneNumber as! String
                user.surname = surname as! String
                
                SVProgressHUD.setStatus("Success")
                SVProgressHUD.dismiss(withDelay: 2, completion: {
                    let udhetareVC = self.storyboard?.instantiateViewController(withIdentifier: SHUdhetareViewController.className) as! SHUdhetareViewController
                    udhetareVC.currentUser = user
                    self.navigationController?.pushViewController(udhetareVC, animated: true)
                })
            }
        }
    }

    
}
