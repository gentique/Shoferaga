//
//  SHLogInViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase

class SHLogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBAction func logInButton(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: userName.text!, password: passwordTextfield.text!) { (user, error) in
            if error != nil{
                print("there was an error")
                print(error!)
            }
            else{
                print("log in sucessful!")
                print(Auth.auth().currentUser!.uid)
                self.getUserInfo()
                // self.performSegue(withIdentifier: SHUdhetareViewController.segueName, sender: self)
            }
        }
    }
    var someRandomINt : Int = 0
    func getUserInfo(){
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        ref.child("Users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            let isWorker = snapshotValue["Worker"] as! Bool
            
            if isWorker{
                self.performSegue(withIdentifier: SHTaksistListViewController.segueName, sender: self)
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
                
                let udhetareVC = self.storyboard?.instantiateViewController(withIdentifier: SHUdhetareViewController.className) as! SHUdhetareViewController
                udhetareVC.currentUser = user
                self.navigationController?.pushViewController(udhetareVC, animated: true)
            }
        }
    }
    
    func updateSettings(){
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
