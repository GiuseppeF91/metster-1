//
//  CalendarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit

class CalendarViewController: BaseVC, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var pendingEventsButton = SelectionButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    //var mapView = MKMapView(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/6)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/2))
    
    var tableView : UITableView = UITableView()
    
    var pendingArray = ["No", "Comedy", "No", "Yes"]
    
    var annotationsConfirmed = [MKPointAnnotation]()
    var annotationsPending = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Events"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        yesEventsButton.addTarget(self, action: #selector(CalendarViewController.yesEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        yesEventsButton.setTitle("Confirmed", forState: .Normal)
        self.view.addSubview(yesEventsButton)
        
        pendingEventsButton.addTarget(self, action: #selector(CalendarViewController.pendingEventsClicked), forControlEvents: UIControlEvents.TouchUpInside)
        pendingEventsButton.setTitle("Pending", forState: .Normal)
        pendingEventsButton.selected = true
        self.view.addSubview(pendingEventsButton)
        
        //mapView.delegate = self
        //let span = MKCoordinateSpanMake(10, 10)
        //let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4), span: span)
        //mapView.setRegion(region, animated: true)
        //self.view.addSubview(mapView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
        
        //loadMap()
        loadEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/2-50)
    }
    
    func loadEvents() {
        RequestInfo.sharedInstance().postReq("111002")
        { (success, errorString) -> Void in
            self.activityIndicator.startAnimating()
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("couldn't load")
                    //self.activityIndicator.stopAnimating()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("hosted")
                print(Users.sharedInstance().email)
                self.activityIndicator.stopAnimating()
                
                //TODO : Make one array out of accepted and hosted
                //TODO : for each event, find restaurant based on go_with_group
                //TODO : list each event in table view
                
                
                //let okhosted = Users.sharedInstance().hosted as! NSArray
                //for item in okhosted {
                print("ok")
                //print(item)
                // UserVariables.event_id = item as! String
                Users.sharedInstance().query = "sushi"
                //self.findFood()
                // }
            })
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
        tableView.reloadData()
        //loadMap()
    }
    
    func yesEventsClicked() {
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        tableView.reloadData()
        //loadMap()
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return pendingArray.count
        } else {
        return Users.sharedInstance().hosted!.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if pendingEventsButton.selected == true {
            cell.textLabel!.text = pendingArray[indexPath.row]
        } else {
            
            cell.textLabel!.text = Users.sharedInstance().hosted![indexPath.row] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        Users.sharedInstance().event_id = indexPath
        
        let save = UITableViewRowAction(style: .Normal, title: "Save to Events") { action, index in
            print("save button tapped")

            //SAVE TO CONFIRMED EVENTSSSSSS
            
            RequestInfo.sharedInstance().postReq("998000")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Failed at getting foodz")
                        self.alertMessage("Error", message: "Unable to connect.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Success!", message: "Event Confirmed")
                })
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        save.backgroundColor = UIColor.greenColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            
            if self.pendingEventsButton.selected == true {
                //REJECT Invite
                let alert = UIAlertController(title: "Reject Invitation", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    Users.sharedInstance().event_id = indexPath
                    
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
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
                    Users.sharedInstance().event_id = indexPath
                    
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
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
        } else {
            return [delete, save]
        }
    }
}