//
//  SHTaksistWorkViewController.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/19/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit
import Firebase
import MapKit


class SHTaksistWorkViewController: UIViewController {

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var idLabel: UILabel!
    
    var refID: String?
    var currentLocation: CLLocationCoordinate2D?
    var currentPlacemark: MKPlacemark?
    
    var udhetare = Udhetare()
    let ref = Database.database().reference()
    var postRefHandle: DatabaseHandle!
    let locationManager = CLLocationManager()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = refID!
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
        
        ref.child("Request/\(refID!)").updateChildValues(["Accepted" : true])
        getRequestInfo()
        //TODO: On viewDidLoad navbar should be hidden, after the work order is done navbar should appear again so that the user can select another job from the queue
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        //MARK:- Firebase
    func getRequestInfo(){
        ref.child("Request/\(refID!)").observeSingleEvent(of: .value) { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            
            let lat = snapshotValue["lat"] as! Double
            let lon = snapshotValue["lon"] as! Double
            let name = snapshotValue["Name"] as! String
            let surname = snapshotValue["Surname"] as! String
            
            self.udhetare.name = name
            self.udhetare.surname = surname
            //tolazy
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.currentPlacemark = MKPlacemark(coordinate: coordinates)
            
            self.updateMap(with: coordinates, and: "\(self.udhetare.name) \(self.udhetare.surname)")
            print(coordinates)
            print(snapshotValue)
            
            var dict: [String: Any] = ["Shofer-lat" : self.currentLocation!.latitude , "Shofer-lon" : self.currentLocation!.longitude]
            dict.append(with: snapshotValue)
            
            //copy the current data to InProgress
            self.ref.child("InProgress/\(self.refID!)").setValue(dict)
            self.observeInProgress()
            self.deleteRequestRef()
        }
    }

    func deleteRequestRef(){
        ref.child("Request/\(self.refID!)").removeValue()
    }
    
    //TODO: need to set completion status from both sides, then set job as finished
    func observeInProgress(){
        finishButton.isEnabled = true
        postRefHandle = ref.child("InProgress/\(refID!)").observe(.value, with: { (snapshot) in
            let snapshotValue = snapshot.value as? [String : AnyObject] ?? [:]
            
            if (snapshotValue["Udhetar-Finish"] as? Bool) != nil {
                //if successful, this per se means that it's true
                    //we need to check if we are the only one observing, so that we can move the job to "Completed"
                    self.askToFinish(withData: snapshotValue)
                self.ref.child("InProgress/\(self.refID!)").removeValue()
                    self.ref.child("InProgress/\(self.refID!)").removeObserver(withHandle: self.postRefHandle)
        
            }
            print(snapshot.value)
            
        }) 
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        ref.child("InProgress/\(refID!)").updateChildValues(["Shofer-Finish": true])
        ref.child("InProgress/\(refID!)").removeObserver(withHandle: postRefHandle)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.disableAndHideButtons(true)
    }
    
    func askToFinish(withData snapshotDict: [String : AnyObject]){
        ref.child("Completed").childByAutoId().setValue(snapshotDict)
        
        let actionSheet = UIAlertController(title: "Udhetari e ka deklaru qe puna u kry", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sbon mja prish", style: .default, handler: { (action: UIAlertAction ) in
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            self.disableAndHideButtons(true)
            
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func disableAndHideButtons(_ state: Bool){
        self.finishButton.isEnabled = !state
        self.finishButton.isHidden = state
        self.navigationButton.isEnabled = !state
        self.navigationButton.isHidden = state
    }
    
    // Update the map after you get the clients location
    func updateMap(with coor: CLLocationCoordinate2D, and userInfo: String){
        let currentLocationAnnotation = SHAnnotation(title: "Udhetari yt", locationName: userInfo, coordinate: coor)
        mapView.setCenter(coor, animated: true)
        mapView.addAnnotation(currentLocationAnnotation)
    }
    //MARK:- Show Route
    @IBAction func showRouteButton(_ sender: Any) {
        showRoute()
    }
    
    func showRoute(){
        print("INSIDE BUTTON SHOW ROUTER?")
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
            self.navigationButton.isEnabled = false
        }
    }

}
//MARK: - Location Manager
extension SHTaksistWorkViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            let test = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            currentLocation = test
            print(test)
            print("Location updated, sending updates to the mapview")
            //updateMap()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
//MARK:- MapView Functions
extension SHTaksistWorkViewController : MKMapViewDelegate
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



