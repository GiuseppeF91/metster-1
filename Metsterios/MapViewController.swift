//
//  MapViewController.swift
//  Metsterios
//
//  Created by Naveen Mysore on 4/16/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MGLMapView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //full screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width;
        //let screenHeight = screenSize.height;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //Create textview
        let queryBar : UITextField = UITextField(frame : CGRect(x:2, y:25, width: (screenWidth-4), height:40 ))
        queryBar.backgroundColor = UIColor.whiteColor()
        queryBar.placeholder = NSLocalizedString("Search", comment: "")
        queryBar.borderStyle = UITextBorderStyle.RoundedRect;
        //   textView.autocorrectionType = .Yes
        self.view.addSubview( queryBar )
        self.mapView.delegate = self;
        let point = MGLPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: 45.52258, longitude: -122.6732)
        mapView.centerCoordinate = point.coordinate
        point.title = "Voodoo Doughnut"
        point.subtitle = "22 SW 3rd Avenue Portland Oregon, U.S.A."
        
        mapView.addAnnotation(point)
        // Do any additional setup after loading the view.
    }

    // Use the default marker; see our custom marker example for more information
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location:CLLocation = locations[locations.count-1] 
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            print(location.coordinate)
            update_map(location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    func update_map(lat: double_t, lon: double_t){
        var att = mapView.annotations
        mapView.removeAnnotation((att?.popLast())!)
        let point1 = MGLPointAnnotation()
        point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView.centerCoordinate = point1.coordinate
        point1.title = "Voodoo Doughnut"
        point1.subtitle = "22 SW 3rd Avenue Portland Oregon, U.S.A."
        
        mapView.addAnnotation(point1)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
