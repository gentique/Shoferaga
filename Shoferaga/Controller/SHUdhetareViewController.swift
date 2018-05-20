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
    
    @IBOutlet weak var requestButton: UIButton!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    let FIRUserID = Auth.auth().currentUser!.uid
    var postRefHandle: DatabaseHandle!
    var isCenteredOnce = false
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
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
            //qit funksion duhet me e limitu se po rrin tu kriju shum annotations
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
        let ref = Database.database().reference().child("Users/\(FIRUserID)")
        currentUser!.lat = currentLocation!.latitude
        currentUser!.lon = currentLocation!.longitude
        ref.updateChildValues(["lon" : currentLocation!.longitude , "lat" : currentLocation!.latitude])
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
            
            Database.database().reference().child("Request/\(FIRUserID)").setValue(userInfoDict)
            requestButton.setTitle("Anulo", for: .normal)
            return
        case "Anulo":
            requestButton.isEnabled = false
            Database.database().reference().child("Request/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
            Database.database().reference().child("Request/\(FIRUserID)").removeValue()
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
        postRefHandle = Database.database().reference().child("Request/\(FIRUserID)").observe(.value) { (snapshot) in
            
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshot.value)
            print("FIRED UP!")
            self.requestButton.isEnabled = true
            guard let isRequestAccepted = snapshotValue["Accepted"] as? Bool else{ return }
            if isRequestAccepted{
                print(self.postRefHandle)
                Database.database().reference().child("Request/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
                self.statusLabel.text = "Tu e kqyr ku o.. "
                self.observeInProgress()
                self.requestButton.isEnabled = false
                
            }
        }
    }
    
    func observeInProgress(){
        postRefHandle = Database.database().reference().child("InProgress/\(FIRUserID)").observe(.value, with: { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshot.value)
            if (snapshotValue["Shofer-lat"] as? Double) != nil{
                let shoferLat = snapshotValue["Shofer-lat"] as! Double
                let shoferLon = snapshotValue["Shofer-lon"] as! Double
                self.statusLabel.text = "Shoferi u gjet!"
                self.indicatorView.stopAnimating()
                self.updateMap(for: 0, lat: shoferLat, lon: shoferLon)
                self.requestButton.isEnabled = false
                
            }
        })
        
    }
    var currentPlacemark: CLPlacemark?
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

