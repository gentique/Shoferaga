//
//  SHRegisterTaksistViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SHRegisterTaksistViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var surnameTextField: UITextField!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func registerButton(_ sender: Any) {
        registerDriverWithFirebase()
    }
    func registerDriverWithFirebase(){
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextfield.text!) { (user, errorHere) in
            if errorHere != nil{
                print("error")
            }else{
                let userInfo: [String : Any] = ["Name" : self.userNameTextField.text!,
                                                "Surname" : self.surnameTextField.text!,
                                                "Phone Number" : self.phoneNumberTextField.text!,
                                                "Email" : self.emailTextField.text!,
                                                "Money" : 50 ,
                                                "Worker" : true,
                                                "lat" : 0,
                                                "lon" : 0,
                                                "Approved" : false]
                Database.database().reference().child("Users/\(user!.uid)").setValue(userInfo)
                print("SAVED ALL")
                let udhetareVC = self.storyboard?.instantiateViewController(withIdentifier: SHTaksistListViewController.className) as! SHTaksistListViewController
                self.navigationController?.pushViewController(udhetareVC, animated: true)
            }
        }
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
