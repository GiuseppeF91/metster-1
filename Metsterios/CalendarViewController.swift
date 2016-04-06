//
//  CalendarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit

var screenWidth = UIScreen.mainScreen().bounds.width
var screenHeight = UIScreen.mainScreen().bounds.height

class CalendarViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))
    
    var myEventsButton = SelectionButton(frame: CGRectMake(screenWidth/3, (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))
    
    var pendingEventsButton = SelectionButton(frame: CGRectMake(screenWidth*(2/3), (screenHeight/12)+25, screenWidth/3, (screenHeight)/12))
    
    //var mapView = MKMapView(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/6)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/2))
    
    var tableView : UITableView = UITableView()
    
    var annotationsConfirmed = [MKPointAnnotation]()
    var annotationsPending = [MKPointAnnotation]()
    
    var oneTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(2.0 * Double(NSEC_PER_SEC)))
    
    var twoTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.5 * Double(NSEC_PER_SEC)))

    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Events"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        /*
         mapView.delegate = self
         let span = MKCoordinateSpanMake(10, 10)
         let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4), span: span)
         mapView.setRegion(region, animated: true)
         self.view.addSubview(mapView)
         */
        

        dispatch_async(dispatch_get_main_queue(), {
            //loadMap()
            self.loadEvents()
        })
        
        dispatch_after(self.twoTime, self.GlobalMainQueue) {
        
        self.yesEventsButton.addTarget(self, action: #selector(CalendarViewController.yesEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.yesEventsButton.setTitle("Confirmed", forState: .Normal)
        self.view.addSubview(self.yesEventsButton)
            
        self.myEventsButton.addTarget(self, action: #selector(CalendarViewController.myEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.myEventsButton.setTitle("Hosting", forState: .Normal)
            self.view.addSubview(self.myEventsButton)
        
        self.pendingEventsButton.addTarget(self, action: #selector(CalendarViewController.pendingEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.pendingEventsButton.setTitle("Pending", forState: .Normal)
        self.view.addSubview(self.pendingEventsButton)
        self.pendingEventsButton.selected = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
            
        self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, screenHeight/3, screenWidth, (screenHeight/2))
    }
    
    func loadEvents() {
        RequestInfo.sharedInstance().postReq("111002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("couldn't load")
                    self.alertMessage("Error", message: "Unable to load")
                })
                return
            }
            
            dispatch_after(self.oneTime, self.GlobalMainQueue) {

                print("found events")

                print(Users.sharedInstance().hosted)
                print(Users.sharedInstance().pending)
            }
        }
    }
    
    func reloadEvents() {
        loadEvents()
        dispatch_after(self.twoTime, self.GlobalMainQueue) {
           
            self.tableView.reloadData()
        }
    }

   /* func loadMap() {
        mapView.removeAnnotations(annotationsConfirmed)
        mapView.removeAnnotations(annotationsPending)
        if pendingEventsButton.selected == true {
            mapView.addAnnotations(annotationsPending)
        } else {
            mapView.addAnnotations(annotationsConfirmed)
        }
    } */
    
    func pendingEventsClicked() {
        pendingEventsButton.selected = true
        yesEventsButton.selected = false
        myEventsButton.selected = false
        tableView.reloadData()
        //loadMap()
    }
    
    func yesEventsClicked() {
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        myEventsButton.selected = false
        tableView.reloadData()
        //loadMap()
    }
    
    func myEventsClicked() {
        yesEventsButton.selected = false
        pendingEventsButton.selected = false
        myEventsButton.selected = true
        tableView.reloadData()
        //loadMap
    }
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return Users.sharedInstance().pending!.count
        }
        if yesEventsButton.selected == true {
            return Users.sharedInstance().joined!.count
        } else {
            return Users.sharedInstance().hosted!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if pendingEventsButton.selected == true {
            
            cell.textLabel!.text = Users.sharedInstance().pending![indexPath.row] as? String
        }
        if yesEventsButton.selected == true {
            
            cell.textLabel!.text = Users.sharedInstance().joined![indexPath.row] as? String
        } else {
            cell.textLabel?.text = Users.sharedInstance().hosted![indexPath.row] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        Users.sharedInstance().event_id = cell?.textLabel?.text
        
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
}