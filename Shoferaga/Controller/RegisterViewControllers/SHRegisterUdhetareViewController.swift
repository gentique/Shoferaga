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

class SHRegisterUdhetareViewController: UIViewController  {
    
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

        //TODO: Needs checks for textields
        //TODO: Upload Picture
        Auth.auth().createUser(withEmail: emailTxtField.text!, password: passwordTxtField.text!) { (user, errorHere) in

            let userInfo: [String : Any] = ["Name" : self.nameTxtField.text!, "Surname" : self.surnameTxtField.text!, "Phone Number" : self.phoneNumberTxtField.text! , "Email" : self.emailTxtField.text! , "Money" : 50 , "Worker" : false, "lat" : 0 , "lon" : 0]
            Database.database().reference().child("Users").child(user!.uid).setValue(userInfo)
            print("SAVED ALL")
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
