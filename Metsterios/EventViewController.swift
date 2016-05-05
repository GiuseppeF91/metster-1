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
    var attvdictionary:Dictionary<String, String>?
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = []
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    var submitButton = SearchButton(frame: CGRectMake((screenWidth)-45, 52, 40, 40))
    var voteButton = UIButton(frame: CGRectMake(5, (screenHeight/2)+65, 70, 30))

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
        
        
        //-----
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.whiteColor()
        //navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        let event_name = Users.sharedInstance().selected_event_name as! String
        navigationItem.title = event_name
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backPressed))
        //let rightButton = UIBarButtonItem(title: "Right", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        //navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)

        
        //-----
        
        
        voteButton.backgroundColor = UIColor.whiteColor()
        voteButton.layer.cornerRadius = 5
        voteButton.layer.borderWidth = 1
        voteButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        voteButton.setTitle("Vote up", forState: UIControlState.Normal)
        voteButton.setTitleColor(UIColor(red: 0, green: 0.6549, blue: 0.9373, alpha: 1.0), forState: UIControlState.Normal)
        voteButton.addTarget(self, action: #selector(EventViewController.votepressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(voteButton)
        voteButton.hidden = true
        
        
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
        
        Users.sharedInstance().places?.removeAllObjects()
        
        submitButton.addTarget(self, action: #selector(self.searchmade), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(submitButton)
        submitButton.hidden = false
        
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
                print (place.name )
                var vote_count = "1"
                print (place)
                if(place.votes.count > 0) {
                    vote_count = String(place.votes.count)
                } else {
                    vote_count = "1"
                }
                self.add_annot(place.latitude, lon: place.longitude, name: place.name, address: place.address, votes: vote_count, place_id: key)
                self.hostedPlaces.insert(place, atIndex: 0)
             }
            }
         }
         // TableView updates when there is new data.
         
         }, withCancelBlock: { error in
         self.alertMessage("Error", message: "Something went wrong.")
         })
        
        var mlat = 0.0
        var mlon = 0.0
         
         for hostedPlace in self.hostedPlaces {
            let latitude = Double(hostedPlace.latitude)
            let longitude = Double(hostedPlace.longitude)
            mlat = mlat + latitude!
            mlon = mlon + longitude!
            print(latitude)
            print(longitude)
            print(hostedPlace.address)
         }
        
        if (self.hostedPlaces.count > 0 ){
            mlat = mlat / Double(hostedPlaces.count)
            mlon = mlon / Double(hostedPlaces.count)
            print ("move to ")
            print(mlat)
            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: mlat,
                                    longitude: mlon),
                                    zoomLevel: 12, animated: true)
        } else {
         // print Users.sharedInstance().lat
            /* seems to be working on phone lets ignore for now
            let lati = Users.sharedInstance().lat as! Double
            let longi = Users.sharedInstance().long as! Double
            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: lati,
                                        longitude: longi),
                                        zoomLevel: 12, animated: true)
             */
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
    
    
    func votepressed(){
        print("vote pressed")
    }
    
    func findFood(query : String, eventid : String) {
        print ("enter findfood")
        Users.sharedInstance().search_mode = "group"
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
                self.voteButton.hidden = false
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
        attvdictionary?.removeAll()
        pinAnnotations.removeAll()
        self.newValues?.removeAllObjects()
        self.names?.removeAllObjects()
        self.images?.removeAllObjects()
        self.categories?.removeAllObjects()
        self.snippets?.removeAllObjects()
        self.details?.removeAllObjects()
        
    }
    
    func add_annot(lat : String, lon : String, name : String, address : String, votes: String, place_id : String){
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
            attndictionary = [name: votes]
        }
        else if var foofoo = attndictionary {
            foofoo[name] = votes
            attndictionary = foofoo
        }
        
        if (attvdictionary == nil) {
            attvdictionary = [name: place_id]
        }
        else if var foofoo = attndictionary {
            foofoo[name] = place_id
            attvdictionary = foofoo
        }
        
        update_map_focus(lpoint)
        
        //attndictionary.
        // fit the map to the annotation(s)
        
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
            Users.sharedInstance().lat = lat as Double
            Users.sharedInstance().long = lon as Double
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
        label.text = dis! + "\nvote"
        return label
        
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        // return UIButton(type: .DetailDisclosure)
        return UIButton(type: .ContactAdd)
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        //mapView.deselectAnnotation(annotation, animated: false)
        let evnt = Users.sharedInstance().event_id as! String
        let alert = UIAlertController(title: "name", message: "Do you want to vote up this location?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                print(Users.sharedInstance().email!)
                
                
                //-- vote up
                let placeid = self.attvdictionary![annotation.title!!]! as String
                print("\(self.ref)/\(evnt)/places/\(placeid)/")
                let myRootRef = Firebase(url: "\(self.ref)/\(evnt)/places/\(placeid)/votes/")
                let eid = Users.sharedInstance().email as! String
                let users = ["2": eid]
                myRootRef.setValue(users)
                
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