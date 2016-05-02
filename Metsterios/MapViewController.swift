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

class MapViewController:BaseVC, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MGLMapView!
    var hostedPlaces = [Place]()
    var pinAnnotations = [MGLPointAnnotation]()
    var attndictionary:Dictionary<String, String>?
    var attkdictionary:Dictionary<String, String>?
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = [] // holds all places for a given query
    let newValuespeople : NSMutableArray? = [] // we need to update this for a given place.
    var modeImage : UIImageView?
    
    var publishSwitch = UISwitch(frame:CGRectMake(screenWidth-60, (screenHeight/2)+65, 0, 0))

    
    // publish button
    
    let publishbutton = UIButton(frame: CGRectMake(5, (screenHeight/2)+65, 70, 30))

    // list attbrs
    var names : NSMutableArray? = []
    var images : NSMutableArray? = []
    var categories : NSMutableArray? = []
    var snippets : NSMutableArray? = []
    var details : NSMutableArray? = []
    var dictionary = NSDictionary()
    
    var placesTableView : UITableView = UITableView()
    
    var tap :UITapGestureRecognizer?
    
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
        
        //let screenWidth = screenSize.width;
        //let screenHeight = screenSize.height;
        
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.rowHeight = 100
        self.view.addSubview(self.placesTableView)
        placesTableView.hidden = true
 
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        publishSwitch.on = true
        publishSwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(publishSwitch)
        publishSwitch.hidden = true
        publishbutton.hidden = true
        
        
        
        publishbutton.backgroundColor = UIColor.whiteColor()
        publishbutton.layer.cornerRadius = 5
        publishbutton.layer.borderWidth = 1
        publishbutton.layer.borderColor = UIColor.lightGrayColor().CGColor
        publishbutton.setTitle("Publish", forState: UIControlState.Normal)
        publishbutton.setTitleColor(UIColor(red: 0, green: 0.6549, blue: 0.9373, alpha: 1.0), forState: UIControlState.Normal)
        publishbutton.addTarget(self, action: #selector(MapViewController.publishpressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(publishbutton)
        
        //0, (screenHeight/2)+100
        modeImage = UIImageView(frame:CGRectMake(screenWidth-100, (screenHeight/2)+65, 40, 40))
        modeImage?.layer.masksToBounds = false
        modeImage?.layer.cornerRadius = modeImage!.frame.width/2
        modeImage?.clipsToBounds = true
        self.view.addSubview(modeImage!)
        
        let image : UIImage = UIImage(named:"place")!
        self.modeImage!.image = image
        self.modeImage?.hidden = true
        Users.sharedInstance().search_mode = "private"
        //
        
        publishSwitch.addTarget(self, action: #selector(MapViewController.switchpressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        // close keyboard
        //Looks for single or multiple taps.
        tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap!)
        
        //view.removeGestureRecognizer(tap)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
                                    longitude: -73.9843407),
                                    zoomLevel: 12, animated: false)

        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
    }
    
    
    func publishpressed(sender:UIButton) {
        print ("publish")
        
        if (Users.sharedInstance().publish_place == nil ) {
            publish_this_place("none")
            
        } else {
            print (Users.sharedInstance().publish_place)
            publish_this_place(Users.sharedInstance().publish_place as! String)
        }
    }
    
    func switchpressed(switchState: UISwitch) {
        if switchState.on {
            print("The Switch is On")
            let image : UIImage = UIImage(named:"place")!
            self.modeImage!.image = image
            Users.sharedInstance().search_mode = "private"
        } else {
            print("The Switch is Off")
            let image : UIImage = UIImage(named:"people")!
            self.modeImage!.image = image
            Users.sharedInstance().search_mode = "public"
        }
        
        self.placesTableView.reloadData()
    }
    
    func findFood(query : String, eventid : String) {
        loadingact.startAnimating()
        
        newValues?.removeAllObjects()
        
        Users.sharedInstance().query = query
        Users.sharedInstance().event_id = "email-"+(Users.sharedInstance().email! as! String)
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
                        self.newValues!.addObject(restaurantInfo) // adding place info here
                        
                    } catch {
                        print(error)
                    }
                }
                
                // newValues will have the data
                for value in self.newValues! {
                    print ("----")
                    print (value)
                    let placeid = value.valueForKey("key") as! String
                    let latitude = value.valueForKey("latitude") as! String
                    let longitude = value.valueForKey("longitude") as! String
                    let name = value.valueForKey("name") as! String
                    
                    let address = value.valueForKey("address") as! String
                    let drivedistance = value.valueForKey("drivedistance") as! String
                    print(latitude)
                    print(longitude)
                    print(drivedistance)
                    self.add_annot(latitude, lon: longitude, name: name, address: address, dis: drivedistance, placeid: placeid)
                }
                //self.mapView.addAnnotations(self.pinAnnotations)
                //self.mapView.showAnnotations(self.pinAnnotations, animated: false)
                //self.mapView.selectAnnotation((self.mapView.annotations?.first)!, animated: true)
                self.loadingact.stopAnimating()
                self.publishSwitch.hidden = false
                self.publishbutton.hidden = false
                self.modeImage?.hidden = false
                self.placesTableView.hidden = false
                self.placesTableView.reloadData()
                self.placesTableView.bringSubviewToFront(self.view)
            }
        }
        
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        self.view.removeGestureRecognizer(self.tap!)
    }
    
    func keyboardWasShown(notification: NSNotification) {
       self.view.addGestureRecognizer(self.tap!)
    }
    
    // action for query bar
    // handle quries here.
    @IBAction func querymade(sender: UITextField) {
        
        print(sender.text)
        let query = sender.text
        let eventid = "10103884620845432--event--18"
        
        
        //-- clean data of previous search
        clean_data()
        
        findFood(query!, eventid: eventid)
        
    }
    
    func clean_data(){
        
        if ( mapView.annotations?.count > 0 ) {
            let annt = mapView.annotations
            for at in annt!{
                mapView.removeAnnotation(at)
            }

        }
        attndictionary?.removeAll()
        attkdictionary?.removeAll()
        pinAnnotations.removeAll()
        self.newValues?.removeAllObjects()
        self.names?.removeAllObjects()
        self.images?.removeAllObjects()
        self.categories?.removeAllObjects()
        self.snippets?.removeAllObjects()
        self.details?.removeAllObjects()
        
    }
    
    func add_annot(lat : String, lon : String, name : String, address : String, dis: String, placeid: String){
        let lpoint = MGLPointAnnotation()
        lpoint.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
        lpoint.title = name
        lpoint.subtitle = address
        mapView.addAnnotation(lpoint)
        
        // fit the map to the annotation(s)
        mapView.showAnnotations(mapView.annotations!, animated: false)
        
        // pop-up the callout view
        // mapView.selectAnnotation(lpoint, animated: true)
        pinAnnotations.append(lpoint)
        // attndictionary.setValue(dis, forKey: name as String)
        
        if (attndictionary == nil) {
            attndictionary = [name: dis]
        } else if var foofoo = attndictionary {
            foofoo[name] = dis
            attndictionary = foofoo
        }
        if (attkdictionary == nil) {
            attkdictionary = [placeid: name]
        } else if var foofoo = attkdictionary {
            foofoo[placeid] = name
            attkdictionary = foofoo
        }
        
        //attndictionary.
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
            Users.sharedInstance().lat = lat
            Users.sharedInstance().long = lon
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
        let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
        label.textAlignment = .Right
        label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        label.font = UIFont.systemFontOfSize(18)
        let dis = attndictionary![annotation.title!!]
        label.numberOfLines = 0;
        label.text = dis! + "\nmins"
        
        
        return label
        
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        // return UIButton(type: .DetailDisclosure)
        return UIButton(type: .InfoDark)
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        //mapView.deselectAnnotation(annotation, animated: false)
        
        if(Users.sharedInstance().search_mode as! String == "public") {
           print("public")
        } else {
        
            print("private")
            Users.sharedInstance().publish_place = annotation.title as String!!
        }
        
    }
    
    
    func publish_this_place(place : String) {
        
        //refer dictonary and get palce name
        
        if(place == "none") {
        
            let alert = UIAlertController(title: "place select a place.",
                                          message: "",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            
            self.presentViewController(alert,
                                       animated: true,
                                       completion: nil)
            
            alert.addAction(UIAlertAction(title: "OK",
                style: .Default,
                handler: { action in
                    switch action.style {
                    case .Default:
                        print("default")
                        
                    case .Cancel:
                        print("cancel")
                        
                    case .Destructive:
                        print("destructive")
                    }
            }))

            
            
            
        } else {
            let name = attkdictionary![place]
            let alert = UIAlertController(title: name,
                                      message: "Do you want to post this place? You can meet similar people who are interested to try this place out.",
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
            alert.addAction(UIAlertAction(title: "No",
                style: UIAlertActionStyle.Default,
                handler: nil))
        
            self.presentViewController(alert,
                                   animated: true,
                                   completion: nil)
        
            alert.addAction(UIAlertAction(title: "Yes",
                style: .Default,
                handler: { action in
                    switch action.style {
                        case .Default:
                            print("default")
                            print(Users.sharedInstance().email!)
                            self.tryout(place)
                    
                        case .Cancel:
                            print("cancel")
                    
                        case .Destructive:
                            print("destructive")
                    }
            }))

        }
    }
    
    func findpeople(title : String) {
        newValuespeople?.removeAllObjects()
        Users.sharedInstance().tryout_people = []
        let key = title
        Users.sharedInstance().tryout_place_id = key
        RequestInfo.sharedInstance().postReq("997667")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("Found people")
                print(Users.sharedInstance().tryout_people)
                self.newValuespeople!.addObject(Users.sharedInstance().tryout_people!)
            })
        }
        
        
    
    }
    

    
    func tryout(title : String) {
        Users.sharedInstance().tryout_message = "I Would love to try out this place!!"
        let key = title
        Users.sharedInstance().tryout_place_id = key
        RequestInfo.sharedInstance().postReq("997666")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
               print("Your search is in public")
            })
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        placesTableView.frame = CGRectMake(0, (screenHeight/2)+100, screenWidth, (screenHeight/2)-50)
    }
    
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
  
        if (Users.sharedInstance().search_mode as! String == "private") {
        
            if tableView == placesTableView  {
                if Users.sharedInstance().places == nil {
                    count = 0
                } else {
                    count = Users.sharedInstance().places!.count
                }
            }
        } else {
            if(Users.sharedInstance().tryout_people == nil){
                count = 0
            } else {
                let people = Users.sharedInstance().tryout_people as! NSDictionary
                count = people.allKeys.count
            }
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        
        let cell = PlaceTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if (Users.sharedInstance().search_mode as! String == "private") {

            if Users.sharedInstance().places != nil {
                
                for item in newValues! {
                    print ("item ----")
                    print (item)
                /*
                 address, category, coordinates, image, name, phone, ratings, review_count, snippet
                */
                    let newName = item.valueForKey("name")
                    self.names?.addObject(newName!)
                
                    let newImage = item.valueForKey("image_url")
                    self.images?.addObject(newImage!)
                
                    let category = item.valueForKey("category")
                    self.categories?.addObject(category!)
                    // placeDescpLabel
                
                    let snippet = item.valueForKey("snippet")
                    let ratings = item.valueForKey("ratings")
                    // let review_count = item.valueForKey("review_count")
                    let details = ratings!
                    self.details?.addObject(details)
                    self.snippets?.addObject(snippet!)
                    print("---->")
                    print(newName)
                
                }
                Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            
            // setup cell values here...
            cell.placeNameLabel!.text = names![indexPath.row] as? String
            cell.placeDescpLabel!.text = categories![indexPath.row] as? String
            cell.placeSnippetLabel!.text = snippets![indexPath.row] as? String
            cell.placedetailsLabel!.text = details![indexPath.row] as? String
            
            
            let url = NSURL(string: images![indexPath.row] as! String)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.placeImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
        }
            
        } else if (Users.sharedInstance().search_mode as! String == "public") {
        
            
            if(Users.sharedInstance().tryout_people != nil){
            
            let people = Users.sharedInstance().tryout_people as! NSDictionary
            let keys = people.allKeys
            for key in keys {
                
                let payload = people.valueForKey(key as! String)
                let data: NSData = payload!.dataUsingEncoding(NSUTF8StringEncoding)!
                
                do {
                    let jsonR = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    print (jsonR.valueForKey("name") as! String)
                    cell.placeNameLabel!.text = jsonR.valueForKey("name") as? String
                    
                    print(jsonR.valueForKey("fb_id") as? String)
                    
                    let access = jsonR.valueForKey("fb_id") as! String
                    let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
                    let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
                    ) { (responseData, responseUrl, error) -> Void in
                        if let data = responseData{
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                cell.placeImage!.image = UIImage(data: data)
                                //let image : UIImage = UIImage(data: data)!
                                //cache.set(value: image.asData(), key: "profile_image.jpg")
                            })
                        }
                    }
                    task.resume()

                    
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
                
            }
        }
        
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("comer gere")
        
            Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            print(Users.sharedInstance().place_id)
            let item = newValues![indexPath.row]
            print ("selected.")
            print (item)
        
        let att = pinAnnotations[indexPath.row]
        
        update_map_focus(att)
    
        Users.sharedInstance().publish_place = Users.sharedInstance().place_id as! String
        
        
        // make find people req
        if(Users.sharedInstance().search_mode as! String == "private") {
            print("finding people")
            findpeople(Users.sharedInstance().publish_place as! String)
        }
        
        /*
         mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: att.coordinate.latitude,
         longitude: att.coordinate.longitude), zoomLevel: 12, animated: false)
         */
        print(att)
    }

    
    func update_map_focus(att : MGLPointAnnotation) {
        
        let point1 = MGLPointAnnotation()
        point1.coordinate = att.coordinate
        //mapView.flyToCamera(<#T##camera: MGLMapCamera##MGLMapCamera#>, completionHandler: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(point1.coordinate,
                                    zoomLevel: 12, animated: true)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.mapView.selectAnnotation(att, animated: true) // set att
        }
        
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
