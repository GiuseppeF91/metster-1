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

    
    @IBOutlet var searchbar: UITextField!

    var notice = UILabel(frame: CGRectMake(0, (screenHeight/2)+70, screenWidth-40, 40))
    
    @IBOutlet var mapView: MGLMapView!
    var hostedPlaces = [Place]()
    var pinAnnotations = [MGLPointAnnotation]()
    var attndictionary:Dictionary<String, String>?
    var attkdictionary:Dictionary<String, String>?
    var attyelpdictionary:Dictionary<String, String>?
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = [] // holds all places for a given query
    let newValuespeople : NSMutableArray? = [] // we need to update this for a given place.
    
    var publishSwitch = UISwitch(frame:CGRectMake(2, 25, 32, 32))
    var submitButton = SearchButton(frame: CGRectMake((screenWidth)-43, 25, 32, 32))
    
    var findpeopleBtn = findpeopleButton(frame: CGRectMake((screenWidth)-70, (screenHeight/2)+85, 68, 38))
    var findplacesBtn = findplacesButton(frame: CGRectMake((screenWidth)-70, (screenHeight/2)+85, 68, 38))

    var noticeLabel = UILabel(frame: CGRectMake(0, (screenHeight/2)+100, screenWidth, 12.0))
    
    var toggle_mode = "places"
    // publish button

    // list attbrs
    var names : NSMutableArray? = []
    var images : NSMutableArray? = []
    var categories : NSMutableArray? = []
    var snippets : NSMutableArray? = []
    var ratings : NSMutableArray? = []
    var reviewcount : NSMutableArray? = []
    var dictionary = NSDictionary()
    
    var lineView : UIView?
    var lineViewBanner : UIView?
    var placesTableView : UITableView = UITableView()
    
    var tap :UITapGestureRecognizer?
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
    let dropDown = DropDown()
    
    @IBOutlet var loadingact: UIActivityIndicatorView!
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //full screen size
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        //-----
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 20)) // Offset by 20 pixels vertically to take the status bar into account
        
        let color1 = hexStringToUIColor("#fd5c63")
        navigationBar.backgroundColor = color1
        //navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        //navigationItem.title = "Search"
        /*
        let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "bannerimg")
        imageView.image = image
        navigationItem.titleView = imageView
        */
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
        
        
        //-----
        
        
        //let screenWidth = screenSize.width;
        //let screenHeight = screenSize.height;
        
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.rowHeight = 100
        self.view.addSubview(self.placesTableView)
        placesTableView.hidden = true
        placesTableView.userInteractionEnabled = true
        placesTableView.bringSubviewToFront(self.view)
        

        notice.textAlignment = NSTextAlignment.Left
        notice.text = ""
        notice.font = UIFont(name: "HelveticaNeue-Bold", size: 10)
        notice.adjustsFontSizeToFitWidth = true
        view.addSubview(self.notice)
        notice.hidden = true
        
        //self.placesTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapTableView"))
        //placesTableView.gestureRecognizers?.last!.delegate = self
 
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        publishSwitch.on = true
        publishSwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(publishSwitch)
        publishSwitch.hidden = false
        
        
        lineView = UIView(frame: CGRectMake(0, (screenHeight/2)+100, screenWidth, 15.0))
        lineView!.layer.borderWidth = 15.0
        let color2 = hexStringToUIColor("#47D509")
        lineView!.layer.borderColor = color2.CGColor
        self.view.addSubview(lineView!)
        lineView!.hidden = true
        
        noticeLabel.textAlignment = NSTextAlignment.Left
        noticeLabel.text = "test"
        noticeLabel.textColor = UIColor.whiteColor()
        noticeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        noticeLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.noticeLabel)
        noticeLabel.hidden = true
        
        /*
        lineViewBanner = UIView(frame: CGRectMake(0, (screenHeight/2)+97, screenWidth, 3.0))
        lineViewBanner!.layer.borderWidth = 3.0
        let color2 = hexStringToUIColor("#47D509")
        lineViewBanner!.layer.borderColor = color2.CGColor
        self.view.addSubview(lineViewBanner!)
        lineViewBanner!.hidden = false
        */
        
        searchbar.placeholder = "search private: e.g sushi, pizza..."
        
        submitButton.addTarget(self, action: #selector(self.searchmade), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(submitButton)
        submitButton.hidden = false
        
        findpeopleBtn.addTarget(self, action: #selector(self.findpeoplepressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(findpeopleBtn)
        findpeopleBtn.hidden = true
        
        findplacesBtn.addTarget(self, action: #selector(self.findpeoplepressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(findplacesBtn)
        findplacesBtn.hidden = true
        
        Users.sharedInstance().search_mode = "private"
        //
        
        publishSwitch.addTarget(self, action: #selector(MapViewController.switchpressed), forControlEvents: UIControlEvents.TouchUpInside)
        
        // close keyboard
        //Looks for single or multiple taps.
        tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap!)
        
        //view.removeGestureRecognizer(tap!)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
                                    longitude: -73.9843407),
                                    zoomLevel: 12, animated: false)

        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        //init drop down
        dropDown.dataSource = [
            "American",
            "Italian",
            "Chinese",
            "Japanese",
            "Indian",
            "Mexican",
            "Korean"
        ]
        
        dropDown.selectionAction = { [unowned self] (index, item) in
            self.searchbar.text = item
        }
        
        dropDown.anchorView = searchbar
        dropDown.bottomOffset = CGPoint(x: 0, y:searchbar.bounds.height)
        
    }
    
    
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func findpeoplepressed(sender:UIButton) {
        print ("toggle button pressed")
        
        if(self.toggle_mode == "people" ){
           self.toggle_mode = "places"// flip
           self.placesTableView.reloadData() // loads places
           self.findplacesBtn.hidden = true
           self.findpeopleBtn.hidden = false
           let count = Users.sharedInstance().places!.count
           let quer = Users.sharedInstance().query as! String
           noticeLabel.text = "  \(count) places found for search \(quer)"
           noticeLabel.hidden = false
            
        } else {
           self.toggle_mode = "people" // flip
           self.placesTableView.reloadData() // loads people
            self.findplacesBtn.hidden = false
            self.findpeopleBtn.hidden = true
            var count = 0
            if(Users.sharedInstance().tryout_people == nil){
                count = 0
            } else {
                let people = Users.sharedInstance().tryout_people as! NSArray
                count = people.count
            }
            
            let quer = Users.sharedInstance().query as! String
            if (count == 1) {
                noticeLabel.text = "  \(count) person nearby interested in \(quer)"
            } else {
                noticeLabel.text = "  \(count) people nearby interested in \(quer)"
            }
            noticeLabel.hidden = false
        }
        
        // this logic needs to moved
        /*
        if (Users.sharedInstance().publish_place == nil ) {
            publish_this_place("none")
            
        } else {
            print (Users.sharedInstance().publish_place)
            publish_this_place(Users.sharedInstance().publish_place as! String)
        }
 */
    }
    
    func switchpressed(switchState: UISwitch) {
        if switchState.on {
            print("The Switch is On")
            Users.sharedInstance().search_mode = "private"
            searchbar.text = ""
            searchbar.placeholder = "search private: e.g sushi, pizza..."
            submitButton.setImage(UIImage(named: "privatesearch"), forState: UIControlState.Normal)
        } else {
            print("The Switch is Off")
            Users.sharedInstance().search_mode = "public"
            searchbar.text = ""
            searchbar.placeholder = "search public: e.g sushi, pizza..."
            submitButton.setImage(UIImage(named: "search"), forState: UIControlState.Normal)
        }
        
    }
    
    func findFood(query : String, eventid : String) {
        
        //mapView = MGLMapView(frame: CGRectMake(0, 0, screenWidth, screenHeight/2))
        //self.mapView.sendSubviewToBack(self.view)
        //self.mapView.resignFirstResponder()
        //self.mapView.frame = CGRectMake(0, 0, screenWidth, screenHeight/2)
        self.toggle_mode = "places" // reset mode to places when search made
        
        if (Users.sharedInstance().search_mode as! String == "public") {
            // publish this search
        }
        
        /*
        self.findplacesBtn.hidden = true
        self.findpeopleBtn.hidden = false
        */
        
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
                    let yelp_url = value.valueForKey("url") as! String
                    
                    let address = value.valueForKey("address") as! String
                    let drivedistance = value.valueForKey("drivedistance") as! String
                    print(latitude)
                    print(longitude)
                    print(drivedistance)
                    self.add_annot(latitude, lon: longitude, name: name, address: address, dis: drivedistance, placeid: placeid, url: yelp_url)
                }
                //self.mapView.addAnnotations(self.pinAnnotations)
                //self.mapView.showAnnotations(self.pinAnnotations, animated: false)
                //self.mapView.selectAnnotation((self.mapView.annotations?.first)!, animated: true)
                self.loadingact.stopAnimating()
                self.publishSwitch.hidden = false
                self.findpeopleBtn.hidden = false
                self.placesTableView.hidden = false
                self.lineView!.hidden = false
                self.placesTableView.reloadData()
                self.placesTableView.bringSubviewToFront(self.view)
                
                let count = Users.sharedInstance().places!.count
                let quer = Users.sharedInstance().query as! String
                self.noticeLabel.text = "  \(count) places found for search \(quer)"
                self.noticeLabel.hidden = false
                
                self.findpeople()
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
        
        if(self.searchbar.hasText()) {
            findFood(query!, eventid: eventid)
        } else {
            print("no text")
        }
        
    }
    
    func clean_data(){
        
        if ( mapView.annotations?.count > 0 ) {
            let annt = mapView.annotations
            for at in annt!{
                mapView.removeAnnotation(at)
            }

        }
        attyelpdictionary?.removeAll()
        attndictionary?.removeAll()
        attkdictionary?.removeAll()
        pinAnnotations.removeAll()
        self.newValues?.removeAllObjects()
        self.names?.removeAllObjects()
        self.images?.removeAllObjects()
        self.categories?.removeAllObjects()
        self.snippets?.removeAllObjects()
        self.ratings?.removeAllObjects()
        self.reviewcount?.removeAllObjects()
        
    }
    
    
    func searchmade(){
        
        print ("searching")
        
        let query = searchbar.text! as String
        let eventid = "10103884620845432--event--18"
        
        
        //-- clean data of previous search
        clean_data()
        if(self.searchbar.hasText()) {
            findFood(query, eventid: eventid)
        } else {
            print("no text")
        }
        
    }
    
    func add_annot(lat : String, lon : String, name : String, address : String, dis: String, placeid: String, url: String){
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
        
        if (attyelpdictionary == nil) {
            attyelpdictionary = [name: url]
        } else if var foofoo = attyelpdictionary {
            foofoo[name] = url
            attyelpdictionary = foofoo
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
        
        let url = attyelpdictionary![annotation.title!!]! as String
        print(url)
        
        
        //---
        
        print ("yelp")
        let webfburl : NSURL = NSURL(string: url)!
        if (UIApplication.sharedApplication().canOpenURL(webfburl)){
            UIApplication.sharedApplication().openURL(webfburl)
        } else {
            UIApplication.sharedApplication().openURL(webfburl)
        }
        
        //----
        
        UIPasteboard.generalPasteboard().string = annotation.subtitle!
    
        let alert = UIAlertController(title: "address copied to clipboard.",
                                      message: " Go to your favorite navigation app and paste the address to navigate.",
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
    
    func findpeople() {
        newValuespeople?.removeAllObjects()
        Users.sharedInstance().tryout_people = []
        let key = title
        Users.sharedInstance().tryout_place_id = key
        RequestInfo.sharedInstance().postReq("998100")
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
                let peoplenb = Users.sharedInstance().tryout_people as! NSArray
                print(peoplenb.count)
                for person in peoplenb {
                    print(person)
                }
                self.newValuespeople!.addObject(Users.sharedInstance().tryout_people!)
            })
        }
    }
    
    
    func onTapChat(sender:UIButton)
    {
        
        
        //Users.sharedInstance().event_id = myHostedevents[Int(sender.tag)].eventid
        let fbid = Users.sharedInstance().event_id!.componentsSeparatedByString("--")
        let fid = String(fbid[0])
        print(Users.sharedInstance().event_id)
        print(Users.sharedInstance().fbid)
        print(fid)
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let chatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatViewController.groupId = Users.sharedInstance().event_id as! String
        chatViewController.sender_id = Users.sharedInstance().fbid  as! String
        chatViewController.username = Users.sharedInstance().name as! String
        
        self.presentViewController(chatViewController, animated: true, completion: nil)
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
        placesTableView.frame = CGRectMake(0, (screenHeight/2)+100, screenWidth, 148)
    }
    
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
  
        // to do clean Users.sharedInstance().places in event view controller
        if (self.toggle_mode == "places") {
        
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
                let people = Users.sharedInstance().tryout_people as! NSArray
                count = people.count
            }
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        
        let cell = MapviewTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if (self.toggle_mode == "places") {

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
                    let review_count = item.valueForKey("review_count")
                    self.ratings?.addObject(ratings!)
                    self.reviewcount?.addObject(review_count!)
                    self.snippets?.addObject(snippet!)
                    print("---->")
                    print(newName)
                
                }
                Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            
            // setup cell values here...
            cell.itemTitle!.text = names![indexPath.row] as? String
            cell.itemline1seg1!.text = categories![indexPath.row] as? String
            cell.itemdescp!.text = snippets![indexPath.row] as? String
            cell.itemline1seg2!.text = ratings![indexPath.row] as? String
            cell.itemline1seg3!.text = reviewcount![indexPath.row] as? String
            
            
            let url = NSURL(string: images![indexPath.row] as! String)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.itemImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
        }
            
        } else if (self.toggle_mode == "people") {
        
            self.notice.text = "people who are also looking for "
            if(Users.sharedInstance().tryout_people != nil){
            
            let people = Users.sharedInstance().tryout_people as! NSArray
            //let keys = people.allKeys
                
            print (people.count)
            let person = people[indexPath.row]
            print (person["p_name"])
            if (Users.sharedInstance().gid as? String == person["p_gid"] as? String ) {
                    // ignore
            } else {
            let name = person["p_name"] as! String
            cell.itemTitle!.text = name
            cell.itemline1seg1!.text = person["p_gid"] as? String
            cell.itemdescp!.text = person["p_aboutme"] as? String
            cell.itemline1seg2!.text = person["p_fmatch"] as? String
            cell.itemline1seg3!.text = person["p_mmatch"] as? String
            var notice = person["poston"] as? String
            notice = "also searched for \(Users.sharedInstance().query!) \(notice!)"
            cell.itemdetail!.text = notice
                
            let access = person["p_fbid"] as! String
            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!)
            { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.itemImage!.image = UIImage(data: data)
                            //let image : UIImage = UIImage(data: data)!
                            //cache.set(value: image.asData(), key: "profile_image.jpg")
                        })
                    }
                }
                task.resume()
            }
            
            cell.chatButton?.setImage(UIImage(named: "Chat Bubble Dots"), forState: .Normal)
            cell.chatButton?.tag = Int(indexPath.row)
            cell.chatButton?.addTarget(self, action: #selector(MapViewController.onmTapChat(_:)), forControlEvents: .TouchUpInside)
                
            cell.fbButton?.setImage(UIImage(named: "fbicon"), forState: .Normal)
            cell.fbButton?.tag = Int(indexPath.row)
            cell.fbButton?.addTarget(self, action: #selector(MapViewController.onfbTap(_:)), forControlEvents: .TouchUpInside)
                
            }
        
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("comer gere")
        
        if (self.toggle_mode == "places") {
            Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            print(Users.sharedInstance().place_id)
            let item = newValues![indexPath.row]
            print ("selected.")
            print (item)
        
        let att = pinAnnotations[indexPath.row]
        
        update_map_focus(att)
    
        Users.sharedInstance().publish_place = Users.sharedInstance().place_id as! String
        } else if (self.toggle_mode == "people") {
            let people = Users.sharedInstance().tryout_people as! NSArray
            let person = people[indexPath.row]
            print (person)
        }
        
        /*
         mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: att.coordinate.latitude,
         longitude: att.coordinate.longitude), zoomLevel: 12, animated: false)
         */
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // myInvitedevents[Int(indexPath.row)]
        
        print ("drag section..")
        
        let save = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            print(Users.sharedInstance().event_id)
            print("save button tapped")
            
            //SAVE TO CONFIRMED EVENTSSSSSS

        }
        save.backgroundColor = lightBlue
        

        return [save]
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
    
    func onmTapChat(sender:UIButton)
    {
        
        let people = Users.sharedInstance().tryout_people as! NSArray
        //let keys = people.allKeys
        
        print (people.count)
        let person = people[sender.tag] // get tag here.
        print (person)
        
        Users.sharedInstance().from_chat = Users.sharedInstance().fbid as! String
        Users.sharedInstance().to_chat = person["p_fbid"] as! String
        Users.sharedInstance().chat_mode = "private"
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let chatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatViewController.groupId = person["p_fbid"] as! String
        chatViewController.sender_id = Users.sharedInstance().fbid  as! String
        chatViewController.username = Users.sharedInstance().name as! String
        
        self.presentViewController(chatViewController, animated: true, completion: nil)
    }
    
    func onfbTap(sender:UIButton)
    {
        
        print ("fb")
        let people = Users.sharedInstance().tryout_people as! NSArray
        //let keys = people.allKeys
        
        print (people.count)
        let person = people[sender.tag] // get tag here.
        print (person)
        
        let pfid = person["p_fbid"] as! String
        let url = "https://www.facebook.com/\(pfid)"
        let furl = "fb://profile/\(pfid)"
        let fbUrl: NSURL = NSURL(string: furl)!
        let webfburl : NSURL = NSURL(string: url)!
        if (UIApplication.sharedApplication().canOpenURL(fbUrl)){
            UIApplication.sharedApplication().openURL(fbUrl)
        } else {
            UIApplication.sharedApplication().openURL(webfburl)
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
