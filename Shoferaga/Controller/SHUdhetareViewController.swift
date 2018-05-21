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
    
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    let FIRUserID = Auth.auth().currentUser!.uid
    let ref = Database.database().reference()
    
    var postRefHandle: DatabaseHandle!
    var isCenteredOnce = false
    var currentPlacemark: CLPlacemark?
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        print(currentUser!.email)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Update map for Matching driver or device
    func updateMap(for type: Int, lat: Double, lon: Double){
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        switch type {
        // update map when driver match is found (display where the driver is)
        case 0:
            let testAnno = SHAnnotation(title: "Shoferaga", locationName: "Knej o", coordinate: coordinate)
            mapView.setCenter(coordinate, animated: true)
            mapView.removeAnnotation(testAnno)
            mapView.addAnnotation(testAnno)
        case 1:
            // send device location to firebase
            sendLocationToFIR()
            if !isCenteredOnce{
                mapView.setCenter(coordinate, animated: false)
                isCenteredOnce = true
            }
        default:
            return
        }
        
    }
    //MARK:- Firebase
    func sendLocationToFIR(){
        currentUser!.lat = currentLocation!.latitude
        currentUser!.lon = currentLocation!.longitude
        ref.child("Users/\(FIRUserID)").updateChildValues(["lon" : currentLocation!.longitude , "lat" : currentLocation!.latitude])
    }
    
    @IBAction func requestButton(_ sender: Any) {
        switch requestButton.currentTitle! {
        case "Hajde Shoferaga":
            observeRequest()
            indicatorView.startAnimating()
            //TODO: kqrye qit tekst
            statusLabel.isHidden = false
            requestButton.isEnabled = false
            
            let userInfoDict: [String : Any] = ["Name" : currentUser!.name,
                                                "Surname" : currentUser!.surname,
                                                "Phone Number" : currentUser!.phoneNumber ,
                                                "Email" : currentUser!.email ,
                                                "Money" : currentUser!.money ,
                                                "Worker" : false,
                                                "lat" : currentUser!.lat ,
                                                "lon" : currentUser!.lon,
                                                "Accepted" : false]
            
            ref.child("Request/\(FIRUserID)").setValue(userInfoDict)
            requestButton.setTitle("Anulo", for: .normal)
            return
        case "Anulo":
            requestButton.isEnabled = false
            ref.child("Request/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
            ref.child("Request/\(FIRUserID)").removeValue()
            requestButton.setTitle("Hajde Shoferaga", for: .normal)
            indicatorView.stopAnimating()
            statusLabel.isHidden = true
            requestButton.isEnabled = true
            return
        default:
            return
        }
    }
    
    func observeRequest(){
        postRefHandle = ref.child("Request/\(FIRUserID)").observe(.value) { (snapshot) in
            
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshot.value)
            print("FIRED UP!")
            self.requestButton.isEnabled = true
            guard let isRequestAccepted = snapshotValue["Accepted"] as? Bool else{ return }
            if isRequestAccepted{
                print(self.postRefHandle)
                self.ref.child("Request/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
                self.statusLabel.text = "Tu e kqyr ku o.. "
                self.observeInProgress()
                self.requestButton.isEnabled = false
            }
        }
    }
    
    func observeInProgress(){
        postRefHandle = ref.child("InProgress/\(FIRUserID)").observe(.value, with: { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshot.value)
            // updates map with shofer location
            if (snapshotValue["Shofer-Finish"] as? Bool) != nil {
                self.askToFinish(withData: snapshotValue)
                self.ref.child("InProgress/\(self.FIRUserID)").removeValue()
                self.ref.child("InProgress/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
            } else if (snapshotValue["Shofer-lat"] as? Double) != nil{
                let shoferLat = snapshotValue["Shofer-lat"] as! Double
                let shoferLon = snapshotValue["Shofer-lon"] as! Double
                
                self.statusLabel.text = "Shoferi u gjet!"
                self.indicatorView.stopAnimating()
                self.updateMap(for: 0, lat: shoferLat, lon: shoferLon)
                
                self.requestButton.isEnabled = false
                self.finishButton.isHidden = false
                self.finishButton.isEnabled = true
            }
        })
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        ref.child("InProgress/\(FIRUserID)").removeObserver(withHandle: postRefHandle)
        ref.child("InProgress/\(FIRUserID)").updateChildValues(["Udhetar-Finish": true])
        statusLabel.text = "Puna u kry"
        hideAndDisableFinishButton(true)
    }
    
    func askToFinish(withData snapshotDict: [String : AnyObject]){
        ref.child("Completed").childByAutoId().setValue(snapshotDict)
        let actionSheet = UIAlertController(title: "Shoferi e ka deklaru qe puna u kry", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Sbon mja prish", style: .default, handler: { (action: UIAlertAction ) in
            self.hideAndDisableFinishButton(true)
            self.statusLabel.text = "Puna u kry"
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func hideAndDisableFinishButton(_ state: Bool){
        finishButton.isHidden = true
        finishButton.isEnabled = false
    }
    @IBAction func displayRoute(_ sender: Any) {
        showRoute()
    }
    func showRoute(){
        print("INSIDE BUTTON SHOW ROUTE?")
        
        guard let currentPlacemark = currentPlacemark else {
            return
        }
        let directionRequest = MKDirectionsRequest()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        // calculate the directions / route
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (directionsResponse, error) in
            guard let directionsResponse = directionsResponse else {
                if let error = error {
                    print("error getting directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = directionsResponse.routes[0]
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add(route.polyline, level: .aboveRoads)
            
            let routeRect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(routeRect), animated: true)
            
        }
    }
}

//MARK: - Location Manager
extension SHUdhetareViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            let test = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            currentLocation = test
            updateMap(for: 1, lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            print(test)
            print("Location updated, sending updates to the mapview")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: Map protocols
extension SHUdhetareViewController : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? SHAnnotation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let location = view.annotation as? SHAnnotation {
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 4.0
        
        return renderer
    }
}

