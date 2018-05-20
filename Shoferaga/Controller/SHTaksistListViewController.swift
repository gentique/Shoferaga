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
import CoreLocation

class SHTaksistListViewController: UIViewController {
    
    
    
    var list: [UdhetareSimpleList] = [UdhetareSimpleList]()
    @IBOutlet weak var tableView: UITableView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        tableView.delegate = self
        tableView.dataSource = self
        
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
            let name = snapshotValue["Name"]
            let lat = snapshotValue["lat"]
            let lon = snapshotValue["lon"]
            
            let userInfo = UdhetareSimpleList()
            print("ARE WE HERE")
            userInfo.Name = name as! String
            userInfo.lat = lat as! Double
            userInfo.lon = lon as! Double
            userInfo.FIRKey = snapshot.key
            
            self.list.append(userInfo)
            self.tableView.reloadData()
            
        }
    }
    
    var tableRowTouched: Int = 0
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHTaksistWorkViewController.segueName{
            if let taksistWorkVC = segue.destination as? SHTaksistWorkViewController{
                taksistWorkVC.refID = list[tableRowTouched].FIRKey
                taksistWorkVC.currentLocation = currentLocation!
            }
        }
    }
    
    func calculateDistance(_ lat1: Double?, lat2: Double, lon1: Double?, lon2: Double) -> String{
        func toRadians(_ degree: Double) -> Double {
            return degree * .pi / 180
        }
        guard let gLat1 = lat1 else{ return "updating.." }
        guard let gLon1 = lon1 else{ return "updating.." }
        let R = 6371e3; // metres
        let φ1 = toRadians(gLat1)
        let φ2 = toRadians(lat2)
        let Δφ = toRadians(lat2-gLat1)
        let Δλ = toRadians(lon2-gLon1)

        let a = sin(Δφ/2) * sin(Δφ/2) + cos(φ1) * cos(φ2) * sin(Δλ/2) * sin(Δλ/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let lenght = Int(R * c)
        if lenght > 1000{
            return "\(lenght/1000) km"
        }else{
            return "\(lenght) m"
        }
    }
    
}

extension SHTaksistListViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            let test = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            currentLocation = test
            tableView.reloadData()
            print("Location updated, sending updates to the tableview")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension SHTaksistListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UdhetareListCell{
            let distance = calculateDistance(currentLocation?.latitude, lat2: list[indexPath.row].lat, lon1: currentLocation?.longitude, lon2: list[indexPath.row].lon)
            cell.updateLabel(with: list[indexPath.row].Name + " Distance: \(distance) " )
            return cell
        }
        return UdhetareListCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableRowTouched = indexPath.row
        performSegue(withIdentifier: SHTaksistWorkViewController.segueName, sender: self)
        

    }
}
