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
    var testTEST: MKMapItem?
    var postRefHandle: DatabaseHandle!
    
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
        mapView.showsUserLocation = true
        
        
        print(currentUser!.email)
        currentPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.82371997408492, longitude: 20.977706909179688))
    }
    func setFirstITEM(){
        let geocoder = CLGeocoder()
        let location2 = CLLocation(latitude: 42.82371997408492, longitude: 20.977706909179688)
        
        geocoder.reverseGeocodeLocation(location2) { (placemarks, error) in
            if placemarks!.count > 0 {
                if let placemark: MKPlacemark = placemarks![0] as? MKPlacemark{
                    self.testTEST =  MKMapItem(placemark: placemark)
                    print("Source set")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Update map for Matching driver or device
    func updateMap(for type: Int, lat: Double, lon: Double){
        switch type {
            // update map when driver match is found (display where the driver is)
        case 0:
            let testAnno = SHAnnotation(title: "Location", locationName: "Current location", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            mapView.setCenter(currentLocation!, animated: true)
            //qit funksion duhet me e limitu se po rrin tu kriju shum annotations
            mapView.removeAnnotation(testAnno)
            mapView.addAnnotation(testAnno)
        case 1:
            // send device location to firebase
            sendLocationToFIR()
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
        observeRequest()
        indicatorView.startAnimating()
        statusLabel.isHidden = false

        
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
    
    func observeRequest(){
        postRefHandle = Database.database().reference().child("Request/\(FIRUserID)").observe(.value) { (snapshot) in
            
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            print(snapshot.value)
            print("FIRED UP!")
            let isRequestAccepted = snapshotValue["Accepted"] as! Bool
            if isRequestAccepted{
                print(self.postRefHandle)
                Database.database().reference().child("Request/\(self.FIRUserID)").removeObserver(withHandle: self.postRefHandle)
                self.statusLabel.text = "Tu e kqyr ku o.. "
                self.observeInProgress()
                
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
            updateMap(for: 1, lat: 0, lon: 0)
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

