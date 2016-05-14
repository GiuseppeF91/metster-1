//
//  CalendarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Mapbox
import Haneke

class CalendarViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    var hostedPlaces = [Place]()
    var pendingPlaces = [Place]()
    var acceptedPlaces = [Place]()
    
    var myHostedevents = [userevents]() // use this for puttting data in the event screen
    var myJoinedevents = [userevents]()
    var myInvitedevents = [userevents]()
    
    var hostedAnnotations = [MGLPointAnnotation]()
    var acceptedAnnotations = [MGLPointAnnotation]()
    var pendingAnnotations = [MGLPointAnnotation]()
    
    let cache = Shared.dataCache
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    
    let locationManager = CLLocationManager()
    
    // button ( yes, pending, accepted) styles
    var yesEventsButton = SelectionButton(frame: CGRectMake(0,
                                                            (screenHeight/2)-((screenHeight)/16),
                                                            screenWidth/3,
                                                            (screenHeight)/16))
    var myEventsButton = SelectionButton(frame: CGRectMake(screenWidth/3,
                                                           (screenHeight/2)-((screenHeight)/16),
                                                           screenWidth/3,
                                                           (screenHeight)/16))
    var pendingEventsButton = SelectionButton(frame: CGRectMake(screenWidth*(2/3),
                                                                (screenHeight/2-((screenHeight)/16)),
                                                                screenWidth/3,
                                                                (screenHeight)/16))

    var tableView : UITableView = UITableView()

    var mapView : MGLMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("====== ENTER Calender View Controller =====")
        Users.sharedInstance().search_mode = "private"
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        loadEvents ({ (success, errorString) in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed.")
                    self.alertMessage("Error", message: "Failure to load Events.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.yesEventsButton.addTarget(self, action: #selector(CalendarViewController.yesEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
                self.yesEventsButton.setTitle("Confirmed", forState: .Normal)
                self.view.addSubview(self.yesEventsButton)
                
                self.myEventsButton.addTarget(self, action: #selector(CalendarViewController.myEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
                self.myEventsButton.setTitle("Hosting", forState: .Normal)
                self.view.addSubview(self.myEventsButton)
                
                self.pendingEventsButton.addTarget(self, action: #selector(CalendarViewController.pendingEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
                self.pendingEventsButton.setTitle("Invites", forState: .Normal)
                self.view.addSubview(self.pendingEventsButton)
                self.pendingEventsClicked()
               
                self.tableView.dataSource = self
                self.tableView.delegate = self
                self.tableView.rowHeight = 100
                self.view.addSubview(self.tableView)
                
                self.tableView.reloadData()
                self.tableView.bringSubviewToFront(self.tableView)
                
            })
        })
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, screenHeight/2, screenWidth, (screenHeight/2)-50)
    }
    
    func loadEvents(completionHandler: (success: Bool, errorString: String?) -> Void) {
        print ("enter loadEvents")
        activityIndicator.startAnimating()
        
        // making account find request to get all events info of this user
        RequestInfo.sharedInstance().postReq("111002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("couldn't load")
                    self.alertMessage("Error", message: "Unable to load")
                    completionHandler(success: false, errorString: "did not load evnts")
                })
                return
            }
            print("found events in loadEvents")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hostedPlaces.removeAll()
                self.acceptedPlaces.removeAll()
                self.pendingPlaces.removeAll()
                self.myHostedevents.removeAll()
                self.myJoinedevents.removeAll()
                self.myInvitedevents.removeAll()

                // shared instance will gave all data from server
                
                for item in Users.sharedInstance().hosted! {
                    Users.sharedInstance().event_id = item
                    self.getHostedEvent(item as! String) // get details of this event from db
                }
                
                for item in Users.sharedInstance().joined! {
                    Users.sharedInstance().event_id = item
                    self.getJoinedEvent(item as! String)
                }
                
                for item in Users.sharedInstance().pending! {
                    Users.sharedInstance().event_id = item
                    self.getInvitedEvent(item as! String)
                }
                
                
                self.loadMap()
                completionHandler(success: true, errorString: nil)
            })
        }
        print ("exit loadEvents")
    }
    
    
// ----------- populate events sections
    func getHostedEvent(item: String) {
        RequestInfo.sharedInstance().postReq("121002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                // event dic in shared instance will have event info
                if(Users.sharedInstance().event_dic[item] != nil) {
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    self.myHostedevents.insert(obj, atIndex: 0)// populate my dictonary
                
                } else {
                    print ("nil for " + item)
                }
            })
            
        }
    }
    
    func getJoinedEvent(item: String) {
        RequestInfo.sharedInstance().postReq("121002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                if(Users.sharedInstance().event_dic[item] != nil) {
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    self.myJoinedevents.insert(obj, atIndex: 0)
                    
                } else {
                    print ("nil for " + item)
                }
            })
        }
    }
    
    func getInvitedEvent(item: String) {
        RequestInfo.sharedInstance().postReq("121002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                if(Users.sharedInstance().event_dic[item] != nil) {
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    self.myInvitedevents.insert(obj, atIndex: 0)
                    
                } else {
                    print ("nil for " + item)
                }
            })
        }
    }
    
//----------------------------------------
    
    func reloadEvents() {
        print ("enter reloadEvents")
        loadEvents ({ (success, errorString) in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                print("Failed.")
                    self.alertMessage("Error", message: "Failure to update events.")
                })
                return
            }
            print("success")
            
            // Delay 2 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
                self.loadMap()
            }
        })
        print ("exit reloadEvents")
    }
    
    func loadMap() {
        print ("enter loadMap")
        /*
        mapView = MGLMapView(frame: CGRectMake(0, (20+screenHeight/20), screenWidth, screenHeight/2), styleURL: MGLStyle.lightStyleURL())
         */
        mapView = MGLMapView(frame: CGRectMake(0, 0, screenWidth, screenHeight/2))
        mapView?.delegate = self

        // set the map's center coordinate
        
        mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: 38.5,
            longitude: -121.4), zoomLevel: 12, animated: false)
        
        mapView?.zoomEnabled = true
        mapView?.scrollEnabled = true
        
        mapView?.showsUserLocation = true
        // mapView?.setRegion(region, animated: true)
        self.view.addSubview(mapView!)
        print("comes till here")
        // Delay 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
            if self.yesEventsButton.selected == true {
                print("yes event selected")
                // find upcoming event and put on map
                for event in self.myJoinedevents {
                    print("my joined event")
                    print(event.eventtime)
                    print(event.eventdate)
                }
                self.yesEventsClicked()
            }
            if self.myEventsButton.selected == true {
                print("my event selected")
                self.myEventsClicked()
           
            } else {
                print("pending event selected")
                self.pendingEventsClicked()
            }
        }
        activityIndicator.stopAnimating()
        print ("exit loadMap")
    }
   
    
//----------------- Map population
    func pendingEventsClicked() {
        print ("enter pendingEventsClicked")
        pendingEventsButton.selected = true
        yesEventsButton.selected = false
        myEventsButton.selected = false
        let allAnnotations = self.mapView!.annotations
        if (allAnnotations?.count > 0 ){
            self.mapView!.removeAnnotations(allAnnotations!)
            self.pendingAnnotations.removeAll()
            self.hostedAnnotations.removeAll()
            self.acceptedAnnotations.removeAll()
        }
        self.tableView.reloadData()
   
        for pendingPlace in pendingPlaces {
            // set map to your location
            let latitude = Double(pendingPlace.latitude)
            let longitude = Double(pendingPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = pendingPlace.name
            annotation.subtitle = pendingPlace.address
            self.pendingAnnotations.append(annotation)
            mapView!.addAnnotations(self.pendingAnnotations)
            
            // updat the map center
            // set the map's center coordinate
            mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude!,
                longitude: longitude!), zoomLevel: 12, animated: false)
            
            // get he next closest pending event and add to map
            
        }
        //self.loadMap()
         print ("exit pendingEventsClicked")
    }
    
    func yesEventsClicked() {
        print ("enter yesEventsClicked")
        
        //-- finding next confirmed event
        for event in self.myJoinedevents{
            print(event.eventdate)
        }
        //---
        
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        myEventsButton.selected = false
        let allAnnotations = self.mapView!.annotations
        if (allAnnotations?.count > 0 ){
            self.mapView!.removeAnnotations(allAnnotations!)
            self.pendingAnnotations.removeAll()
            self.hostedAnnotations.removeAll()
            self.acceptedAnnotations.removeAll()
        }
        self.tableView.reloadData()
        for acceptedPlace in acceptedPlaces {
            let latitude = Double(acceptedPlace.latitude)
            let longitude = Double(acceptedPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = acceptedPlace.name
            annotation.subtitle = acceptedPlace.address
            self.acceptedAnnotations.append(annotation)
            mapView!.addAnnotations(self.acceptedAnnotations)
            // updat the map center
            // set the map's center coordinate
            mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude!,
                longitude: longitude!), zoomLevel: 12, animated: false)
        }
        //self.loadMap()
        print ("exit yesEventsClicked")
    }
    
    func myEventsClicked() {
        print ("enter myEventsClicked")
        
        //-- finding next confirmed event
        for event in self.myHostedevents{
            let aString: String = event.eventdate as String
            let newDate = aString.stringByReplacingOccurrencesOfString("/", withString: "-")
            print(newDate)
            print(event.eventtime)
            //let dateString = event.eventdate as String // change to your date format
            
            let dateString = "2014-07-15T00:30:00.000Z" // change to your date format
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            
            let date = dateFormatter.dateFromString(dateString)
            print(date)
        }
        //---

        
        yesEventsButton.selected = false
        pendingEventsButton.selected = false
        myEventsButton.selected = true
        let allAnnotations = self.mapView!.annotations
        if (allAnnotations?.count > 0 ){
            self.mapView!.removeAnnotations(allAnnotations!)
            self.pendingAnnotations.removeAll()
            self.hostedAnnotations.removeAll()
            self.acceptedAnnotations.removeAll()
        }
        self.tableView.reloadData()
        for hostedPlace in hostedPlaces {
            
            print (hostedPlace)
            let latitude = Double(hostedPlace.latitude)
            let longitude = Double(hostedPlace.longitude)
            let annotation = MGLPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = hostedPlace.name
            annotation.subtitle = hostedPlace.address
            self.hostedAnnotations.append(annotation)
            mapView!.addAnnotations(self.hostedAnnotations)
            // updat the map center
            // set the map's center coordinate
            mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: latitude!,
                longitude: longitude!), zoomLevel: 12, animated: false)
            print ("----")
            print (latitude)
            print (longitude)
            print (hostedPlace.name)
            print (hostedPlace.address)
            print ("---")
        }
        
        for ev in myHostedevents {
            print("hosted places")
            print (ev)
        }
        //self.loadMap()
        print ("exit myEventsClicked")
    }
//------------------
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return myInvitedevents.count
        }
        if yesEventsButton.selected == true {
            return myJoinedevents.count
        } else {
            return myHostedevents.count
        }
    }
    
    var selectCell: Bool = false
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print ("enter tableView for listting")
        let cell = EventTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        if pendingEventsButton.selected == true {
            let acceptedPlace = myInvitedevents[indexPath.row]
            Users.sharedInstance().event_id = acceptedPlace.eventid
            let fbid = Users.sharedInstance().event_id!.componentsSeparatedByString("--")
            let fid = fbid[0]
            cell.eventHostLabel.text = myInvitedevents[Int(indexPath.row)].eventhostname
            cell.eventDescpLabel.text = myInvitedevents[Int(indexPath.row)].eventdesp
            cell.eventTimeLabel.text = myInvitedevents[Int(indexPath.row)].eventtime
            cell.eventDateLabel.text = myInvitedevents[Int(indexPath.row)].eventdate
            cell.eventNameLabel.text = myInvitedevents[Int(indexPath.row)].eventname
            
            // get the user facebook id and get the pic for that.
            //---- cache image management
            let ckey = fid
            cache.fetch(key: ckey).onFailure { data in
                
                print ("data was not found in cache")
                let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
                
                let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
                ) { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.userImage!.image = UIImage(data: data)
                            let image : UIImage = UIImage(data: data)!
                            self.cache.set(value: image.asData(), key: ckey)
                        })
                    }
                }
                task.resume()
                
            }
            
            cache.fetch(key: ckey).onSuccess { data in
                print ("data was found in cache")
                let image : UIImage = UIImage(data: data)!
                cell.userImage!.image = image
            }
            //-----
            return cell
        }
        if yesEventsButton.selected == true {
            
            // get data from myevent
            
            print (indexPath.row)
            Users.sharedInstance().event_id = myJoinedevents[Int(indexPath.row)].eventid
            let fbid = Users.sharedInstance().event_id!.componentsSeparatedByString("--")
            let fid = fbid[0]
            print(Users.sharedInstance().event_id)
            print(fid)
            cell.eventHostLabel.text = myJoinedevents[Int(indexPath.row)].eventhostname
            cell.eventDescpLabel.text = myJoinedevents[Int(indexPath.row)].eventdesp
            cell.eventTimeLabel.text = myJoinedevents[Int(indexPath.row)].eventtime
            cell.eventDateLabel.text = myJoinedevents[Int(indexPath.row)].eventdate
            cell.eventNameLabel.text = myJoinedevents[Int(indexPath.row)].eventname //hostedPlace.eventname
            
            // get the user facebook id and get the pic for that.
            //---- cache image management
            let ckey = fid
            cache.fetch(key: ckey).onFailure { data in
                
                print ("data was not found in cache")
                let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
                
                let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
                ) { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.userImage!.image = UIImage(data: data)
                            let image : UIImage = UIImage(data: data)!
                            self.cache.set(value: image.asData(), key: ckey)
                            print("caching image of")
                            print(cell.eventHostLabel.text)
                        })
                    }
                }
                task.resume()
                
            }
            
            cache.fetch(key: ckey).onSuccess { data in
                print ("data was found in cache")
                let image : UIImage = UIImage(data: data)!
                cell.userImage!.image = image
            }
            //-----
            
            return cell
        } else {
            
            // get data from myevent
            
            print (indexPath.row)
            Users.sharedInstance().event_id = myHostedevents[Int(indexPath.row)].eventid
            let fbid = Users.sharedInstance().event_id!.componentsSeparatedByString("--")
            let fid = String(fbid[0])
            print(Users.sharedInstance().event_id)
            print(Users.sharedInstance().fbid)
            print(fid)
            cell.eventHostLabel.text = myHostedevents[Int(indexPath.row)].eventhostname
            cell.eventDescpLabel.text = myHostedevents[Int(indexPath.row)].eventdesp
            cell.eventTimeLabel.text = myHostedevents[Int(indexPath.row)].eventtime
            cell.eventDateLabel.text = myHostedevents[Int(indexPath.row)].eventdate
            cell.eventNameLabel.text = myHostedevents[Int(indexPath.row)].eventname //hostedPlace.eventname
            
            let image : UIImage = UIImage(named:"slide")!
            cell.slideImage!.image = image
            
            cell.chatButton?.setImage(UIImage(named: "Chat Bubble Dots"), forState: .Normal)
            cell.chatButton?.tag = Int(indexPath.row)
            cell.chatButton?.addTarget(self, action: #selector(CalendarViewController.onTapChat(_:)), forControlEvents: .TouchUpInside)
            // get the user facebook id and get the pic for that.
            //---- cache image management
            let ckey = fid
            cache.fetch(key: ckey).onFailure { data in
                
                print ("data was not found in cache")
                let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
                
                let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
                ) { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.userImage!.image = UIImage(data: data)
                            let image : UIImage = UIImage(data: data)!
                            self.cache.set(value: image.asData(), key: ckey)
                        })
                    }
                }
                task.resume()
                
            }
            
            cache.fetch(key: ckey).onSuccess { data in
                print ("data was found in cache")
                let image : UIImage = UIImage(data: data)!
                cell.userImage!.image = image
            }
            //-----
        
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print ("enter select option")
        
        if(self.pendingEventsButton.selected == true) {
         
            let pendingPlace = myInvitedevents[Int(indexPath.row)]
            Users.sharedInstance().event_id = pendingPlace.eventid
            Users.sharedInstance().selected_event_name = pendingPlace.eventname
            Users.sharedInstance().selected_event_data = pendingPlace
            let mapViewVC = EventViewController()
            let controller: UIViewController = UIViewController()
            controller.view.backgroundColor = UIColor.whiteColor()
            self.presentViewController(mapViewVC, animated: true, completion: nil)
            print (pendingPlace)
            
        }
        
        if(self.yesEventsButton.selected == true) {
         
            let confirmedPlace = myJoinedevents[indexPath.row]
            Users.sharedInstance().event_id = confirmedPlace.eventid
            Users.sharedInstance().selected_event_name = confirmedPlace.eventname
            Users.sharedInstance().selected_event_data = confirmedPlace
            let mapViewVC = EventViewController()
            let controller: UIViewController = UIViewController()
            controller.view.backgroundColor = UIColor.whiteColor()
            self.presentViewController(mapViewVC, animated: true, completion: nil)
            print (confirmedPlace)
        }
        
        if(self.myEventsButton.selected == true) {
            
            
            let hostedPlace = myHostedevents[indexPath.row]
            Users.sharedInstance().event_id = hostedPlace.eventid
            Users.sharedInstance().selected_event_name = hostedPlace.eventname
            Users.sharedInstance().selected_event_data = hostedPlace
            let mapViewVC = EventViewController()
            let controller: UIViewController = UIViewController()
            controller.view.backgroundColor = UIColor.whiteColor()
            self.presentViewController(mapViewVC, animated: true, completion: nil)
          //self.navigationController!.pushViewController(mapViewVC, animated: true)
            
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let customCell = self.tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
        customCell.eventDateLabel.hidden = false
        customCell.eventTimeLabel.hidden = false
        customCell.eventNameLabel.hidden = false
        customCell.eventHostLabel.hidden = false
        customCell.eventDescpLabel.hidden = false
        customCell.userImage!.hidden = false
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if pendingEventsButton.selected == true {
            //let pendingPlace = pendingPlaces[indexPath.row]
            let pendingPlace = myInvitedevents[Int(indexPath.row)]
            Users.sharedInstance().event_id = pendingPlace.eventid
        }
        if yesEventsButton.selected == true {
            let confirmedPlace = myJoinedevents[indexPath.row]
            Users.sharedInstance().event_id = confirmedPlace.eventid
        }
        if myEventsButton.selected == true {
            let hostedPlace = myHostedevents[indexPath.row]
            Users.sharedInstance().event_id = hostedPlace.eventid
        }
        
        print ("drag section..")
        
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
                    self.reloadEvents()
                })
            }
        }
        save.backgroundColor = lightBlue
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            print(Users.sharedInstance().event_id)
            
            if self.pendingEventsButton.selected == true {
                //REJECT Invite
                let alert = UIAlertController(title: "Reject Invitation", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    RequestInfo.sharedInstance().postReq("998002")
                    { (success, errorString) -> Void in
                        guard success else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.alertMessage("Error", message: "Unable to connect.")
                            })
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            print("suucssssss")
                            self.alertMessage("Success!", message: "Event Removed")
                            self.reloadEvents()
                        })
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                //DELETE Confirmed Event 
                let alert = UIAlertController(title: "Delete Event", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    RequestInfo.sharedInstance().postReq("121001")
                    { (success, errorString) -> Void in
                        guard success else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.alertMessage("Error", message: "Unable to connect.")
                            })
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            print("suucssssss")
                            self.alertMessage("Success", message: "Event Deleted")
                            self.reloadEvents()
                        })
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        delete.backgroundColor = darkBlue
        
        if yesEventsButton.selected == true {
            return [delete]
        }
        if myEventsButton.selected == true {
            return [delete]
        } else {
            return [delete, save]
        }
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
            let point1 = MGLPointAnnotation()
            let lat = Double(location.coordinate.latitude)
            let lon = Double(location.coordinate.longitude)
            Users.sharedInstance().lat = lat
            Users.sharedInstance().long = lon
            point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            mapView?.setCenterCoordinate(point1.coordinate, animated: true)
            //mapView?.setCenterCoordinate(point1.coordinate)
            // new location update present location : TODO
        }
    }
    
    func onTapChat(sender:UIButton)
    {
        
        
        Users.sharedInstance().event_id = myHostedevents[Int(sender.tag)].eventid
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
    
    /*//Links to URL in Safari Browswer
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let link = NSURLRequest(URL: NSURL(string: annotationView.annotation!.subtitle!!)!)
        UIApplication.sharedApplication().openURL(link.URL!)
    }*/
}