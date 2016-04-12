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
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))
    var myEventsButton = SelectionButton(frame: CGRectMake(screenWidth/3, (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))
    var pendingEventsButton = SelectionButton(frame: CGRectMake(screenWidth*(2/3), (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))

    var tableView : UITableView = UITableView()
    var annotations = [MKPointAnnotation]()
    var mapView : MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Events"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
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
                self.pendingEventsButton.setTitle("Pending", forState: .Normal)
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
            print("found events")
            
            dispatch_async(dispatch_get_main_queue(), {
                self.hostedPlaces = []
                self.acceptedPlaces = []
                self.pendingPlaces = []
                
                for item in Users.sharedInstance().hosted! {
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
                
                for item in Users.sharedInstance().pending! {
                    let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    event_ref.observeEventType(.Value, withBlock: { snapshot in
                        
                        //Loads hosts places from Firebase...
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let place = Place(key: key, dictionary: postDictionary)
                                    
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
                
                for item in Users.sharedInstance().joined! {
                    let event_ref = Firebase(url: "\(self.ref)/\(item)/places")
                    event_ref.observeEventType(.Value, withBlock: { snapshot in
                        
                        //Loads hosts places from Firebase...
                        if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                            for snap in snapshots {
                                if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
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
                self.loadMap()
                completionHandler(success: true, errorString: nil)
            })
        }
    }
    
    func reloadEvents() {
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
    }
    
    func loadMap() {
        mapView = MKMapView(frame: CGRectMake(0, screenHeight/12+screenHeight/12+25, screenWidth, screenHeight/3.5))
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
            self.currentButton()
        } 
    }
    
    func currentButton() {
          print("getting annots")
        if self.yesEventsButton.selected == true {
            self.yesEventsClicked()
        }
        if self.myEventsButton.selected == true {
            self.myEventsClicked()
        } else {
            self.pendingEventsClicked()
        }
    }
    
    func pendingEventsClicked() {
        pendingEventsButton.selected = true
        yesEventsButton.selected = false
        myEventsButton.selected = false
        tableView.reloadData()
        mapView!.removeAnnotations(annotations)
        
        for pendingPlace in pendingPlaces {
            let latitude = Double(pendingPlace.latitude)
            let longitude = Double(pendingPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = pendingPlace.name
            annotation.subtitle = pendingPlace.address
            self.annotations.removeAll()
            self.annotations.append(annotation)
            mapView!.addAnnotations(self.annotations)
        }
    }
    
    func yesEventsClicked() {
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        myEventsButton.selected = false
        tableView.reloadData()
        mapView!.removeAnnotations(annotations)
        
        for acceptedPlace in acceptedPlaces {
            let latitude = Double(acceptedPlace.latitude)
            let longitude = Double(acceptedPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = acceptedPlace.name
            annotation.subtitle = acceptedPlace.address
            self.annotations.removeAll()
            self.annotations.append(annotation)
            mapView!.addAnnotations(self.annotations)
        }
    }
    
    func myEventsClicked() {
        yesEventsButton.selected = false
        pendingEventsButton.selected = false
        myEventsButton.selected = true
        tableView.reloadData()
        mapView!.removeAnnotations(annotations)
        
        for hostedPlace in hostedPlaces {
            let latitude = Double(hostedPlace.latitude)
            let longitude = Double(hostedPlace.longitude)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = hostedPlace.name
            annotation.subtitle = hostedPlace.address
            self.annotations.removeAll()
            self.annotations.append(annotation)
            mapView!.addAnnotations(self.annotations)
        }
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return pendingPlaces.count
        }
        if yesEventsButton.selected == true {
            return acceptedPlaces.count
        } else {
            return hostedPlaces.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = EventTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
    
        if pendingEventsButton.selected == true {
            let pendingPlace = pendingPlaces[indexPath.row]
            Users.sharedInstance().event_id = pendingPlace.eventid
            cell.eventPlaceLabel.text = pendingPlace.name
            cell.eventAddressLabel.text = pendingPlace.address
            cell.eventTimeLabel.text = pendingPlace.eventtime
            cell.eventDateLabel.text = pendingPlace.eventdate
            cell.eventNameLabel.text = pendingPlace.eventname
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
            return cell
        } else {
            let hostedPlace = hostedPlaces[indexPath.row]
            Users.sharedInstance().event_id = hostedPlace.eventid
            cell.eventPlaceLabel.text = hostedPlace.name
            cell.eventAddressLabel.text = hostedPlace.address
            cell.eventTimeLabel.text = hostedPlace.eventtime
            cell.eventDateLabel.text = hostedPlace.eventdate
            cell.eventNameLabel.text = hostedPlace.eventname
            return cell
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        if pendingEventsButton.selected == true {
            let pendingPlace = pendingPlaces[indexPath.row]
            Users.sharedInstance().event_id = pendingPlace.eventid
        }
        if yesEventsButton.selected == true {
            let confirmedPlace = acceptedPlaces[indexPath.row]
            Users.sharedInstance().event_id = confirmedPlace.eventid
        } else {
            let hostedPlace = hostedPlaces[indexPath.row]
            Users.sharedInstance().event_id = hostedPlace.eventid
        }
        
        let save = UITableViewRowAction(style: .Normal, title: "Save to Events") { action, index in
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
        save.backgroundColor = UIColor.greenColor()
        
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
        delete.backgroundColor = UIColor.grayColor()
        
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