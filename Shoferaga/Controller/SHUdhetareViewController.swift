//
//  SHUdhetareViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/17/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth


class SHUdhetareViewController: UIViewController {
    
    var currentUser: Udhetare?
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    let FIRUserID = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        print(currentUser!.email)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var mapView: MKMapView!

    
    func updateMap(){
        let currentLocationAnnotation = SHAnnotation(locationName: "Your Current Location", coordinate: currentLocation!)
        mapView.setCenter(currentLocation!, animated: true)
        
//        let currentUser = Auth.auth().currentUser!
//        let userInfo: [String : Any] = ["Name" : curren, "Surname" : self.surnameTxtField.text!, "Phone Number" : self.phoneNumberTxtField.text!]
        sendLocationToFIR()
        mapView.addAnnotation(currentLocationAnnotation)
    }
    
    func sendLocationToFIR(){
        let ref = Database.database().reference().child("Users/\(FIRUserID)")
        currentUser!.lat = currentLocation!.latitude
        currentUser!.lon = currentLocation!.longitude
        ref.updateChildValues(["lon" : currentLocation!.longitude , "lat" : currentLocation!.latitude])
        
    }
    
    
    @IBAction func requestButton(_ sender: Any) {
        let userInfoDict: [String : Any] = ["Name" : currentUser!.name,
                                            "Surname" : currentUser!.surname,
                                            "Phone Number" : currentUser!.phoneNumber ,
                                            "Email" : currentUser!.email ,
                                            "Money" : currentUser!.money ,
                                            "Worker" : false,
                                            "lat" : currentUser!.lat ,
                                            "lon" : currentUser!.lon,
                                            "Accepted" : false]
        
        Database.database().reference().child("Request/\(FIRUserID)").setValue(userInfoDict)
    }
    
    func test(){
        Database.database().reference().child("Request").observe(.value) { (snapshot) in
            print("FIRED UP!")
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshotValue)
        }
    }
    

}



//MARK: - Location Manager
extension SHUdhetareViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let test = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            currentLocation = test
            
            updateMap()
            locationManager.delegate = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
