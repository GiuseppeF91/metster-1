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

class CalendarViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate {
    
    var hostedPlaces = [Place]() // use this for annotations
    var pendingPlaces = [Place]()
    var acceptedPlaces = [Place]()
    
    var myHostedevents = [userevents]() // use this for puttting data in the event screen
    var myJoinedevents = [userevents]()
    var myInvitedevents = [userevents]()
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    // button ( yes, pending, accepted) styles
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, 20, screenWidth/3, (screenHeight)/16))
    var myEventsButton = SelectionButton(frame: CGRectMake(screenWidth/3, 20, screenWidth/3, (screenHeight)/16))
    var pendingEventsButton = SelectionButton(frame: CGRectMake(screenWidth*(2/3), 20, screenWidth/3, (screenHeight)/16))

    var tableView : UITableView = UITableView()
    var hostedAnnotations = [MGLPointAnnotation]()
    var acceptedAnnotations = [MGLPointAnnotation]()
    var pendingAnnotations = [MGLPointAnnotation]()
    var mapView : MGLMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                print("success")
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
        // making account find request
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
                self.hostedPlaces = []
                self.acceptedPlaces = []
                self.pendingPlaces = []

                // these loops pull data from firebase for a given eventid
                
                for item in Users.sharedInstance().hosted! {
                    print ("items")
                    print (item)
                    // let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    
                    // get event data from server not firebase
                    Users.sharedInstance().event_id = item
                    self.getHostedEvent(item as! String)
                }
                
                for item in Users.sharedInstance().joined! {
                    print ("items")
                    print (item)
                    // let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    
                    // get event data from server not firebase
                    Users.sharedInstance().event_id = item
                    self.getJoinedEvent(item as! String)
                }
                
                for item in Users.sharedInstance().pending! {
                    print ("items")
                    print (item)
                    // let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    
                    // get event data from server not firebase
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
                    print("Failed at account creation.")
                    self.alertMessage("Error", message: "Your Account Info Was Not Saved.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("event is hereeeee")
                if(Users.sharedInstance().event_dic[item] != nil) {
                    print("we got this...")
                    print ( Users.sharedInstance().event_dic[item] )
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    print (obj.eventid)
                    self.myHostedevents.insert(obj, atIndex: 0)
                
                } else {
                    print ("nil for " + item)
                }
            })
            
            // for annonations
            let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
            event_ref.observeEventType(.Value, withBlock: { snapshot in
                
                //Loads hosts places from Firebase...
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    for snap in snapshots {
                        if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let place = Place(key: key, dictionary: postDictionary)
                            
                            self.hostedPlaces.insert(place, atIndex: 0)
                        }
                    }
                }
                // TableView updates when there is new data.
                self.tableView.reloadData()
                
                }, withCancelBlock: { error in
                    self.alertMessage("Error", message: "Something went wrong.")
            })
            
        }
    }
    
    func getJoinedEvent(item: String) {
        RequestInfo.sharedInstance().postReq("121002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at account creation.")
                    self.alertMessage("Error", message: "Your Account Info Was Not Saved.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("event is hereeeee")
                if(Users.sharedInstance().event_dic[item] != nil) {
                    print("we got this...")
                    print ( Users.sharedInstance().event_dic[item] )
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    print (obj.eventid)
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
                    print("Failed at account creation.")
                    self.alertMessage("Error", message: "Your Account Info Was Not Saved.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("event is hereeeee")
                if(Users.sharedInstance().event_dic[item] != nil) {
                    print("we got this...")
                    print ( Users.sharedInstance().event_dic[item] )
                    let obj = Users.sharedInstance().event_dic[item] as! userevents
                    print (obj.eventid)
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
            let time1 = 8.23
            let time2 = 3.42
            
            // Delay 2 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
                self.loadMap()
            }
        })
        print ("exit reloadEvents")
    }
    
    func loadMap() {
        print ("enter loadMap")
        mapView = MGLMapView(frame: CGRectMake(0, (20+screenHeight/20), screenWidth, screenHeight/2))
        mapView?.delegate = self
        let span = MGLCoordinateSpanMake(4, 4)

        // set the map's center coordinate
        mapView?.setCenterCoordinate(CLLocationCoordinate2D(latitude: 38.5,
            longitude: -121.4), zoomLevel: 12, animated: false)
        
        mapView?.zoomEnabled = true
        mapView?.scrollEnabled = true
        // mapView?.setRegion(region, animated: true)
        self.view.addSubview(mapView!)
        
        let time1 = 8.23
        let time2 = 3.42
        
        // Delay 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            
            if self.yesEventsButton.selected == true {
                self.yesEventsClicked()
            }
            if self.myEventsButton.selected == true {
                self.myEventsClicked()
           
            } else {
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
   
        print ("comes till here..")
        for pendingPlace in pendingPlaces {
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
        }
         print ("exit pendingEventsClicked")
    }
    
    func yesEventsClicked() {
        print ("enter yesEventsClicked")
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
        print ("exit yesEventsClicked")
    }
    
    func myEventsClicked() {
        print ("enter myEventsClicked")
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
            cell.eventHostLabel.text = myHostedevents[Int(indexPath.row)].eventhostname
            cell.eventDescpLabel.text = myInvitedevents[Int(indexPath.row)].eventdesp
            cell.eventTimeLabel.text = " "
            cell.eventDateLabel.text = myInvitedevents[Int(indexPath.row)].eventdate + " " + myInvitedevents[Int(indexPath.row)].eventtime
            cell.eventNameLabel.text = myHostedevents[Int(indexPath.row)].eventname
            
            //let access = Users.sharedInstance().fbid as! String
            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.userImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
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
            cell.eventHostLabel.text = myHostedevents[Int(indexPath.row)].eventhostname
            cell.eventDescpLabel.text = myJoinedevents[Int(indexPath.row)].eventdesp
            cell.eventTimeLabel.text = myJoinedevents[Int(indexPath.row)].eventtime
            cell.eventDateLabel.text = myJoinedevents[Int(indexPath.row)].eventdate
            cell.eventNameLabel.text = myHostedevents[Int(indexPath.row)].eventname //hostedPlace.eventname
            
            // get the user facebook id and get the pic for that.
            
            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.userImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
            
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
            
            // get the user facebook id and get the pic for that.

            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(fid)/picture?type=large")
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.userImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
        
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        RequestInfo.sharedInstance().postReq("121002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at returning data")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("suucssssss")
                if self.pendingEventsButton.selected == true || self.yesEventsButton.selected == true  {
                    let customCell = self.tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
                    customCell.eventDateLabel.hidden = true
                    customCell.eventTimeLabel.hidden = true
                    customCell.eventNameLabel.text = "Invited By"
                    customCell.eventHostLabel.text = Users.sharedInstance().host_email as? String
                    customCell.eventDescpLabel.hidden = true
                    customCell.userImage!.hidden = true
                } else {
                    print ("handle clicked case here...")
                    
                    // frame the in globsl class
                }
                
            })
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
            let pendingPlace = pendingPlaces[indexPath.row]
            Users.sharedInstance().event_id = pendingPlace.eventid
        }
        if yesEventsButton.selected == true {
            let confirmedPlace = acceptedPlaces[indexPath.row]
            Users.sharedInstance().event_id = confirmedPlace.eventid
        }
        if myEventsButton.selected == true {
            let hostedPlace = hostedPlaces[indexPath.row]
            Users.sharedInstance().event_id = hostedPlace.eventid
        }
        
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
    
    
    /*//Links to URL in Safari Browswer
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let link = NSURLRequest(URL: NSURL(string: annotationView.annotation!.subtitle!!)!)
        UIApplication.sharedApplication().openURL(link.URL!)
    }*/
}