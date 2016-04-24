//
//  MapViewController.swift
//  Metsterios
//
//  Created by Naveen Mysore on 4/16/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Mapbox
import Firebase

class EventViewController:BaseVC, MGLMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    var hostedPlaces = [Place]()
    var pinAnnotations = [MGLPointAnnotation]()
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = []
    var pickerDataSource = ["White", "Red", "Green", "Blue"];
    
    
    @IBOutlet var pickerView: UIPickerView!
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
    @IBOutlet var loadingact: UIActivityIndicatorView!
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
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
        
        // close keyboard
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.pickerView.dataSource = self;
        
        self.pickerView.delegate = self;
        
        pickerView.hidden = true
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
            longitude: -73.9843407),
                                    zoomLevel: 12, animated: false)
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        /*
         self.hostedPlaces = []
         let event_ref = Firebase(url:"https://metsterios.firebaseio.com/10103884620845432--event--18/places")
         // Read data and react to changes
         event_ref.observeEventType(.Value, withBlock: { snapshot in
         
         //Loads hosts places from Firebase...
         if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
         for snap in snapshots {
         if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
         let key = snap.key
         let place = Place(key: key, dictionary: postDictionary)
         print (place.address )
         self.add_annot(place.latitude, lon: place.longitude, name: place.name)
         self.hostedPlaces.insert(place, atIndex: 0)
         }
         }
         }
         // TableView updates when there is new data.
         
         }, withCancelBlock: { error in
         self.alertMessage("Error", message: "Something went wrong.")
         })
         
         
         for hostedPlace in self.hostedPlaces {
         let latitude = Double(hostedPlace.latitude)
         let longitude = Double(hostedPlace.longitude)
         print(latitude)
         print(longitude)
         print(hostedPlace.address)
         }
         */
        
    }
    
    
    
    func findFood(query : String, eventid : String) {
        if ( mapView.annotations?.count > 0 ) {
            clean_map()
        }
        loadingact.startAnimating()
        
        newValues?.removeAllObjects()
        
        Users.sharedInstance().query = query
        Users.sharedInstance().event_id = eventid
        print (Users.sharedInstance().query)
        print (Users.sharedInstance().event_id)
        
        RequestInfo.sharedInstance().postReq("999000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at getting foodz")
                    self.alertMessage("Error", message: "Unable to connect.")
                })
                return
            }
            
            dispatch_after(self.popTime, self.GlobalMainQueue) {
                
                for item in Users.sharedInstance().places! {
                    print(Users.sharedInstance().place_id)
                    let restaurantData : NSData = (item.dataUsingEncoding(NSUTF8StringEncoding))!
                    
                    do {
                        let restaurantInfo = try NSJSONSerialization.JSONObjectWithData(restaurantData , options: .AllowFragments) as! NSMutableDictionary
                        self.newValues!.addObject(restaurantInfo)
                    } catch {
                        print(error)
                    }
                }
                
                self.pickerDataSource.removeAll()
                // newValues will have the data
                for value in self.newValues! {
                    print ("----")
                    let latitude = value.valueForKey("latitude") as! String
                    let longitude = value.valueForKey("longitude") as! String
                    let name = value.valueForKey("name") as! String
                    let address = value.valueForKey("address") as! String
                    print(latitude)
                    print(longitude)
                    self.add_annot(latitude, lon: longitude, name: name, address: address)
                    self.pickerDataSource.append(name)
                }
                //self.mapView.addAnnotations(self.pinAnnotations)
                //self.mapView.showAnnotations(self.pinAnnotations, animated: false)
                //self.mapView.selectAnnotation((self.mapView.annotations?.first)!, animated: true)
                self.pickerView.reloadAllComponents();
                self.pickerView.hidden = false
                self.loadingact.stopAnimating()
            }
        }
        
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // action for query bar
    // handle quries here.
    @IBAction func querymade(sender: UITextField) {
        
        print(sender.text)
        let query = sender.text
        let eventid = "10103884620845432--event--18"
        
        findFood(query!, eventid: eventid)
        
    }
    
    // clear map
    func clean_map(){
        let annt = mapView.annotations
        for at in annt!{
            mapView.removeAnnotation(at)
        }
        pickerView.hidden = true
    }
    
    // add all point annotations here for the map
    func add_annot(lat : String, lon : String, name : String, address : String){
        let lpoint = MGLPointAnnotation()
        lpoint.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
        lpoint.title = name
        lpoint.subtitle = address + "\n" + "Hello"
        mapView.addAnnotation(lpoint)
        
        // fit the map to the annotation(s)
        mapView.showAnnotations(mapView.annotations!, animated: false)
        
        // pop-up the callout view
        // mapView.selectAnnotation(lpoint, animated: true)
        pinAnnotations.append(lpoint)
        // fit the map to the annotation(s)
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location:CLLocation = locations[locations.count-1]
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            print(location.coordinate)
            let point1 = MGLPointAnnotation()
            let lat = Double(location.coordinate.latitude)
            let lon = Double(location.coordinate.longitude)
            point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            mapView.centerCoordinate = point1.coordinate
            // new location update present location : TODO
        }
    }
    
    // Use the default marker; see our custom marker example for more information
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        let label = UILabel(frame: CGRectMake(0, 0, 60, 50))
        label.textAlignment = .Right
        label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        label.text = "金閣寺"
        return label
        
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        // return UIButton(type: .DetailDisclosure)
        return UIButton(type: .InfoDark)
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        //mapView.deselectAnnotation(annotation, animated: false)
        UIAlertView(title: annotation.title!!, message: "A lovely place.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
    }
    
    /*
     func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
     return nil
     }
     
     func mapView(mapView: MGLMapView, layerForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
     
     return nil
     }
     
     
     func mapView(mapView: MGLMapView, calloutViewForAnnotation annotation: MGLAnnotation) -> UIView? {
     // Only show callouts for `Hello world!` annotation
     return nil
     }
     
     func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
     // Optionally handle taps on the callout
     print("Tapped the callout for: \(annotation)")
     // Hide the callout
     //mapView.deselectAnnotation(annotation, animated: true)
     }
     
     func mapView(mapView: MGLMapView, viewForAnnotation annotation: MGLAnnotation){
     
     print ("cicekd")
     }
     */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let att = pinAnnotations[row]
        mapView.selectAnnotation(att, animated: true) // set att
        /*
         mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: att.coordinate.latitude,
         longitude: att.coordinate.longitude), zoomLevel: 12, animated: false)
         */
        print(att)
        print (row)
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
