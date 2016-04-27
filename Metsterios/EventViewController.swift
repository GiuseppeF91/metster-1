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

class EventViewController:BaseVC, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MGLMapView!
    var hostedPlaces = [Place]()
    var pinAnnotations = [MGLPointAnnotation]()
    var attndictionary:Dictionary<String, String>?
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = []
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    var submitButton = SubmitButton(frame: CGRectMake((screenWidth/2)+10, 100, (screenWidth/2)-30, 40))
    var gobackButton = BackButton(frame: CGRectMake(10, 100, (screenWidth/2)-30, 40))
    // list attbrs
    var names : NSMutableArray? = []
    var images : NSMutableArray? = []
    var categories : NSMutableArray? = []
    var snippets : NSMutableArray? = []
    var details : NSMutableArray? = []
    var dictionary = NSDictionary()
    
    var placesTableView : UITableView = UITableView()
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
 
    @IBOutlet var loadingact: UIActivityIndicatorView!
    
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("enter event view controller")
        print(Users.sharedInstance().event_id)
        //full screen size
        // let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        //let screenWidth = screenSize.width;
        //let screenHeight = screenSize.height;
        
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.rowHeight = 100
        self.view.addSubview(self.placesTableView)
        placesTableView.hidden = true
        var recognizer = UISwipeGestureRecognizer(target: self, action: Selector("didSwipe"))
        placesTableView.addGestureRecognizer(recognizer)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        submitButton.addTarget(self, action: #selector(self.searchmade), forControlEvents: UIControlEvents.TouchUpInside)
        submitButton.setTitle("Submit", forState: .Normal)
        self.view.addSubview(submitButton)
        submitButton.hidden = false
        
        gobackButton.addTarget(self, action: #selector(self.backPressed), forControlEvents: UIControlEvents.TouchUpInside)
        gobackButton.setTitle("Back", forState: .Normal)
        self.view.addSubview(gobackButton)
        gobackButton.hidden = false
        loadingact.hidden = true
        // close keyboard
        //Looks for single or multiple taps.
        
        //view.removeGestureRecognizer(tap)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
                                                        longitude: -73.9843407),
                                                        zoomLevel: 12, animated: false)
        
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        
        self.hostedPlaces.removeAll()
        let eid = Users.sharedInstance().event_id as! String
        
        let event_ref = Firebase(url: "\(self.ref)/\(eid)/places")
         // Read data and react to changes
         event_ref.observeEventType(.Value, withBlock: { snapshot in
         if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
         for snap in snapshots {
            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                let key = snap.key
                let place = Place(key: key, dictionary: postDictionary)
                print (place.address )
                self.add_annot(place.latitude, lon: place.longitude, name: place.name, address: place.address, dis: "34")
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
        
        
    }
    
    
    
    func didSwipe(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let swipeLocation = recognizer.locationInView(self.placesTableView)
            if let swipedIndexPath = placesTableView.indexPathForRowAtPoint(swipeLocation) {
                if let swipedCell = self.placesTableView.cellForRowAtIndexPath(swipedIndexPath) {
                    print("swipped")
                    print(swipedCell)
                }
            }
        }
    }
    
    func backPressed() {
        print ("back pressed")
        navigationController?.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    func searchmade() {
        print ("search made enter")
        let query = "sushi"
        let eventid = Users.sharedInstance().event_id
        Users.sharedInstance().query = query as String
        //-- clean data of previous search
        //clean_data()
        
        findFood(query, eventid: eventid as! String)
        print ("search made leave")
        
    }
    
    func findFood(query : String, eventid : String) {
        print ("enter findfood")
        loadingact.hidden = false
        loadingact.startAnimating()
        
        if(newValues?.count > 0) {
            newValues?.removeAllObjects()
        }
        
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
                
                // newValues will have the data
                for value in self.newValues! {
                    print ("----")
                    print (value)
                    let latitude = value.valueForKey("latitude") as! String
                    let longitude = value.valueForKey("longitude") as! String
                    let name = value.valueForKey("name") as! String
                    let address = value.valueForKey("address") as! String
                    //let drivedistance = value.valueForKey("drivedistance") as! String
                    print(latitude)
                    print(longitude)
                    //print(drivedistance)
                    //self.add_annot(latitude, lon: longitude, name: name, address: address, dis: drivedistance)
                }
                //self.mapView.addAnnotations(self.pinAnnotations)
                //self.mapView.showAnnotations(self.pinAnnotations, animated: false)
                //self.mapView.selectAnnotation((self.mapView.annotations?.first)!, animated: true)
                self.loadingact.stopAnimating()
                self.loadingact.hidden = true
                self.placesTableView.hidden = false
                self.placesTableView.reloadData()
                self.placesTableView.bringSubviewToFront(self.view)
            }
        }
        
    }

        
    func clean_data(){
        
        if ( mapView.annotations?.count > 0 ) {
            let annt = mapView.annotations
            for at in annt!{
                mapView.removeAnnotation(at)
            }
            
        }
        attndictionary?.removeAll()
        pinAnnotations.removeAll()
        self.newValues?.removeAllObjects()
        self.names?.removeAllObjects()
        self.images?.removeAllObjects()
        self.categories?.removeAllObjects()
        self.snippets?.removeAllObjects()
        self.details?.removeAllObjects()
        
    }
    
    func add_annot(lat : String, lon : String, name : String, address : String, dis: String){
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
        }
        else if var foofoo = attndictionary {
            foofoo[name] = dis
            attndictionary = foofoo
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
        
        let alert = UIAlertController(title: "name", message: "Do you want to vote up this location?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                print(Users.sharedInstance().email!)
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))


        
    }
    
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
        
        if tableView == placesTableView  {
            if Users.sharedInstance().places == nil {
                count = 0
            } else {
                count = Users.sharedInstance().places!.count
            }
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        let cell = PlaceTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        if Users.sharedInstance().places != nil {
            
            for item in newValues! {
                // print (item)
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
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("comer gere")
        
        Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
        print(Users.sharedInstance().place_id)
        let placeid = Users.sharedInstance().place_id
        let item = newValues![indexPath.row]
        let evnt = Users.sharedInstance().event_id as! String
        print ("selected.")
        print (item)
        
        // alert
        
        
        let alert = UIAlertController(title: "name", message: "Do you want to pin this location?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Pin", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                
                /* check if that location is aleardy pinned
                if pinned dont pin again just add it as a vote
                if someone chooses to upvote add vote
                 */
                
                
                var to_fb = item as! Dictionary<String, AnyObject>
                to_fb["votes"] = [Users.sharedInstance().email as! String]
                
                let myRootRef = Firebase(url: "\(self.ref)/\(evnt)/places/\(placeid as! String)/")
                myRootRef.setValue(to_fb)
                
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        print ("enter select option")
        
        let save = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            print(Users.sharedInstance().event_id)
            print("save button tapped")
            
            //SAVE TO CONFIRMED EVENTSSSSSS
            RequestInfo.sharedInstance().postReq("998000")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Failed at saving")
                        self.alertMessage("Error", message: "Unable to connect.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Success!", message: "Event Confirmed")
                })
            }
        }
        save.backgroundColor = lightBlue
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            print(Users.sharedInstance().event_id)

        }
        delete.backgroundColor = darkBlue
   
        return [delete]
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