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

class CalendarViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var hostedPlaces = [Place]()
    var pendingPlaces = [Place]()
    var acceptedPlaces = [Place]()
    
    var myevents = [userevents]()
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    // button ( yes, pending, accepted) styles
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, 20, screenWidth/3, (screenHeight)/16))
    var myEventsButton = SelectionButton(frame: CGRectMake(screenWidth/3, 20, screenWidth/3, (screenHeight)/16))
    var pendingEventsButton = SelectionButton(frame: CGRectMake(screenWidth*(2/3), 20, screenWidth/3, (screenHeight)/16))

    var tableView : UITableView = UITableView()
    var hostedAnnotations = [MKPointAnnotation]()
    var acceptedAnnotations = [MKPointAnnotation]()
    var pendingAnnotations = [MKPointAnnotation]()
    var mapView : MKMapView?
    
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
                
                for item in Users.sharedInstance().joined! {
                    let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    print("\(self.ref)/\(item)/places")
                    event_ref.observeEventType(.Value, withBlock: { snapshot in
                        
                        //Loads hosts places from Firebase...
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    print ("ref1")
                                    print (key)
                                    let place = Place(key: key, dictionary: postDictionary)
                                    
                                    self.acceptedPlaces.insert(place, atIndex: 0)
                                }
                            }
                        }
                        // TableView updates when there is new data.
                        self.tableView.reloadData()
                        
                        }, withCancelBlock: { error in
                            self.alertMessage("Error", message: "Something went wrong.")
                    })
                }
                
                for item in Users.sharedInstance().hosted! {
                    print ("items")
                    print (item)
                    // let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    
                    // get event data from server not firebase
                    Users.sharedInstance().event_id = item
                    self.getEvent(item as! String)
                    /*
                    event_ref.observeEventType(.Value, withBlock: { snapshot in
                        
                        //Loads hosts places from Firebase...
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let place = Place(key: key, dictionary: postDictionary)
                                    print (key)
                                    print (postDictionary)
                                     print ("ref2")
                                    self.hostedPlaces.insert(place, atIndex: 0)
                                }
                            }
                        }
                        // TableView updates when there is new data.
                        self.tableView.reloadData()
                        
                        }, withCancelBlock: { error in
                            self.alertMessage("Error", message: "Something went wrong.")
                    })
                     */
                    
                }
                
                for item in Users.sharedInstance().pending! {
                    let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    event_ref.observeEventType(.Value, withBlock: { snapshot in
                        
                        //Loads hosts places from Firebase...
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let place = Place(key: key, dictionary: postDictionary)
                                    print (key)
                                     print ("ref3")
                                    self.pendingPlaces.insert(place, atIndex: 0)
                                }
                            }
                        }
                        // TableView updates when there is new data.
                        self.tableView.reloadData()
                        
                        }, withCancelBlock: { error in
                            self.alertMessage("Error", message: "Something went wrong.")
                    })
                }
                self.loadMap()
                completionHandler(success: true, errorString: nil)
            })
        }
        print ("exit loadEvents")
    }
    
    
    
    func getEvent(item: String) {
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
                    self.myevents.insert(obj, atIndex: 0)
                
                } else {
                    print ("nil for " + item)
                }
                //let edic = Users.sharedInstance().event_dic[item]
                //self.myevents.insert(edic, atIndex: 0)
                /*
                for evid in Users.sharedInstance().event_dic {
                    let key = String(evid)
                    let edic = Users.sharedInstance().event_dic[key]
                    let place = Place(key: key, dictionary: (edic as? Dictionary<String, AnyObject>)!)
                    self.hostedPlaces.insert(place, atIndex: 0)
                }
                 */

            })
        }
    }
    
    
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
        mapView = MKMapView(frame: CGRectMake(0, (20+screenHeight/20), screenWidth, screenHeight/2))
        mapView?.delegate = self
        let span = MKCoordinateSpanMake(4, 4)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.5, longitude: -121.4), span: span)
        mapView?.zoomEnabled = true
        mapView?.scrollEnabled = true
        mapView?.setRegion(region, animated: true)
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
   
    func pendingEventsClicked() {
        print ("enter pendingEventsClicked")
        pendingEventsButton.selected = true
        yesEventsButton.selected = false
        myEventsButton.selected = false
        let allAnnotations = self.mapView!.annotations
        self.mapView!.removeAnnotations(allAnnotations)
        self.pendingAnnotations.removeAll()
        self.hostedAnnotations.removeAll()
        self.acceptedAnnotations.removeAll()
        self.tableView.reloadData()
   
        for pendingPlace in pendingPlaces {
            let latitude = Double(pendingPlace.latitude)
            let longitude = Double(pendingPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = pendingPlace.name
            annotation.subtitle = pendingPlace.address
            self.pendingAnnotations.append(annotation)
            mapView!.addAnnotations(self.pendingAnnotations)
        }
         print ("exit pendingEventsClicked")
    }
    
    func yesEventsClicked() {
        print ("enter yesEventsClicked")
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        myEventsButton.selected = false
        let allAnnotations = self.mapView!.annotations
        self.mapView!.removeAnnotations(allAnnotations)
        self.pendingAnnotations.removeAll()
        self.hostedAnnotations.removeAll()
        self.acceptedAnnotations.removeAll()
        self.tableView.reloadData()
        
        for acceptedPlace in acceptedPlaces {
            let latitude = Double(acceptedPlace.latitude)
            let longitude = Double(acceptedPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = acceptedPlace.name
            annotation.subtitle = acceptedPlace.address
            self.acceptedAnnotations.append(annotation)
            mapView!.addAnnotations(self.acceptedAnnotations)
        }
        print ("exit yesEventsClicked")
    }
    
    func myEventsClicked() {
        print ("enter myEventsClicked")
        yesEventsButton.selected = false
        pendingEventsButton.selected = false
        myEventsButton.selected = true
        let allAnnotations = self.mapView!.annotations
        self.mapView!.removeAnnotations(allAnnotations)
        self.pendingAnnotations.removeAll()
        self.hostedAnnotations.removeAll()
        self.acceptedAnnotations.removeAll()
        self.tableView.reloadData()
        
        for hostedPlace in hostedPlaces {
            
            print (hostedPlace)
            let latitude = Double(hostedPlace.latitude)
            let longitude = Double(hostedPlace.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = hostedPlace.name
            annotation.subtitle = hostedPlace.address
            self.hostedAnnotations.append(annotation)
            mapView!.addAnnotations(self.hostedAnnotations)
            print ("----")
            print (latitude)
            print (longitude)
            print (hostedPlace.name)
            print (hostedPlace.address)
            print ("---")
        }
        
        for ev in myevents {
            print("hosted places")
            print (ev)
        }
        print ("exit myEventsClicked")
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return pendingPlaces.count
        }
        if yesEventsButton.selected == true {
            return acceptedPlaces.count
        } else {
            return myevents.count
        }
    }
    
    var selectCell: Bool = false
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print ("enter tableView for listting")
        let cell = EventTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        if pendingEventsButton.selected == true {
            let pendingPlace = pendingPlaces[indexPath.row]
            Users.sharedInstance().event_id = pendingPlace.eventid
            cell.eventPlaceLabel.text = pendingPlace.name
            cell.eventAddressLabel.text = pendingPlace.address
            cell.eventTimeLabel.text = pendingPlace.eventtime
            cell.eventDateLabel.text = pendingPlace.eventdate
            cell.eventNameLabel.text = pendingPlace.eventname
            
            let url = NSURL(string: pendingPlace.image_url)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.foodImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
            
            return cell
        }
        if yesEventsButton.selected == true {
            let acceptedPlace = acceptedPlaces[indexPath.row]
            Users.sharedInstance().event_id = acceptedPlace.eventid
            cell.eventPlaceLabel.text = acceptedPlace.name
            cell.eventAddressLabel.text = acceptedPlace.address
            cell.eventTimeLabel.text = acceptedPlace.eventtime
            cell.eventDateLabel.text = acceptedPlace.eventdate
            cell.eventNameLabel.text = acceptedPlace.eventname
            
            let url = NSURL(string: acceptedPlace.image_url)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.foodImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
            return cell
        } else {
            print ("comes here")
            
            // get data from myevent
            
            print (indexPath.row)
            Users.sharedInstance().event_id = myevents[Int(indexPath.row)].eventid
            cell.eventPlaceLabel.text = myevents[Int(indexPath.row)].eventname
            cell.eventAddressLabel.text = myevents[Int(indexPath.row)].eventid
            cell.eventTimeLabel.text = myevents[Int(indexPath.row)].eventtime
            cell.eventDateLabel.text = myevents[Int(indexPath.row)].eventhost
            cell.eventNameLabel.text = "Dinner"//hostedPlace.eventname
            /*
            let url = NSURL(string: hostedPlace.image_url)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.foodImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
             */
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
                    var customCell = self.tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
                    customCell.eventDateLabel.hidden = true
                    customCell.eventTimeLabel.hidden = true
                    customCell.eventNameLabel.text = "Invited By"
                    customCell.eventPlaceLabel.text = Users.sharedInstance().host_email as! String
                    customCell.eventAddressLabel.hidden = true
                    customCell.foodImage!.hidden = true
                }
            })
        }
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var customCell = self.tableView.cellForRowAtIndexPath(indexPath) as! EventTableViewCell
        customCell.eventDateLabel.hidden = false
        customCell.eventTimeLabel.hidden = false
        customCell.eventNameLabel.hidden = false
        customCell.eventPlaceLabel.hidden = false
        customCell.eventAddressLabel.hidden = false
        customCell.foodImage!.hidden = false
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
    
    /*//Links to URL in Safari Browswer
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let link = NSURLRequest(URL: NSURL(string: annotationView.annotation!.subtitle!!)!)
        UIApplication.sharedApplication().openURL(link.URL!)
    }*/
}