//
//  SHUdhetarViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class SHRegisterUdhetareViewController: UIViewController  {
    
    @IBOutlet weak var registerButton: MainLogInButtonsView!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var phoneNumberTxtField: UITextField!
    @IBOutlet weak var surnameTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var profilePicture: AvatarImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func changeProfilePicturePressed(_ sender: Any) {
        showImagePickerActionSheet()
    }
    
    @IBAction func registerButton(_ sender: Any) {
        registerPassangerWithFirebase()

}
func registerPassangerWithFirebase(){
    //TODO: Needs checks for textields, or maybe not
    //TODO: Upload Picture
    registerButton.isEnabled = false
    Auth.auth().createUser(withEmail: emailTxtField.text!, password: passwordTxtField.text!) { (user, error) in
        if error != nil{
            SVProgressHUD.show(withStatus: "Error")
            SVProgressHUD.dismiss(withDelay: 2)
            self.registerButton.isEnabled = true
            return
        }
        let userInfo: [String : Any] = ["Name" : self.nameTxtField.text!,
                                        "Surname" : self.surnameTxtField.text!,
                                        "Phone Number" : self.phoneNumberTxtField.text!,
                                        "Email" : self.emailTxtField.text!,
                                        "Money" : 50,
                                        "Worker" : false,
                                        "lat" : 0,
                                        "lon" : 0]
        
        let udhetare = Udhetare(name: self.nameTxtField.text!, surname: self.surnameTxtField.text!, email: self.emailTxtField.text!, phoneNumber: self.phoneNumberTxtField.text!, money: 50, worker: false, lat: 0, lon: 0)
        
        let refID = user?.uid
        Database.database().reference().child("Users/\(refID!)").setValue(userInfo, withCompletionBlock: { (error, ref) in
            if error != nil{
                SVProgressHUD.show(withStatus: "Error")
                SVProgressHUD.dismiss(withDelay: 2)
                self.registerButton.isEnabled = true
                
            } else{
                SVProgressHUD.show(withStatus: "Success")
                SVProgressHUD.dismiss(withDelay: 1, completion: {
                    let udhetareVC = self.storyboard?.instantiateViewController(withIdentifier: SHUdhetareViewController.className) as! SHUdhetareViewController
                    udhetareVC.currentUser = udhetare
                    self.navigationController?.pushViewController(udhetareVC, animated: true)
                })
            }
        })
        print("SAVED ALL")
    }
    }
}

// MARK: - ImagePicker
extension SHRegisterUdhetareViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func showImagePickerActionSheet(){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action: UIAlertAction ) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("Camera not available")
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Chose from library", style: .default, handler: { (action: UIAlertAction ) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        print(info)
        // asign to which image
        profilePicture.image = image
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
