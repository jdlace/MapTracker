//
//  ViewController.swift
//  Map
//
//  Created by Jonathan Lace on 4/6/16.
//  Copyright © 2016 techrament. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var map: MKMapView!
    
    //create a CLLocationManager object
    var manager: CLLocationManager!
    var previousLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
   
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            manager.requestWhenInUseAuthorization()
            manager.requestAlwaysAuthorization()
        }
        
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        
        map.delegate = self
        map.showsUserLocation = true
        map.mapType = MKMapType(rawValue: 0)!
        map.userTrackingMode = MKUserTrackingMode(rawValue: 1)!
        
        
        let shpLocation = CLLocationCoordinate2D(latitude: 40.7750, longitude: -74.2478)
        let shpAnnotation = MKPointAnnotation()
        shpAnnotation.title = "Seton Hall Prep"
        shpAnnotation.subtitle = "120 Northfield Ave"
        shpAnnotation.coordinate = shpLocation
        
        self.map.addAnnotation(shpAnnotation)
        self.map.showsCompass = true
        self.map.showsScale = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks as? [CLPlacemark]! where placemarks.count > 0 {
                let placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary;
                annotation.title = addressDictionary!["Name"] as? String
                self.map.addAnnotation(annotation)
            }
        })
    }
    

    //CLLocationManagerDelegate methods
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        print("present location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        
        let oldCoordinates = oldLocation.coordinate
        let newCoordinates = newLocation.coordinate
        
        if oldCoordinates.latitude != 0 {
        
        if let oldLocationNew = oldLocation as CLLocation? {
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            map.addOverlay(polyline)
        }
        
        
        if let previousLocationNew = previousLocation as CLLocation?{
            
            //case if previous location exists
            if previousLocation.distanceFromLocation(newLocation) > 500 {
                addAnnotationsOnMap(newLocation)
                previousLocation = newLocation
            }
            
        } else {
            //in case previous location doesn't exist
            addAnnotationsOnMap(newLocation)
            previousLocation = newLocation
        }
    }
}
    
    //MKMapViewDelegate methods
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let lineRenderer = MKPolylineRenderer(overlay: overlay)
            lineRenderer.strokeColor = UIColor.redColor()
            lineRenderer.lineWidth = 5
            return lineRenderer
        }
        
        return MKPolylineRenderer()
    
    }
    

    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
 */

}