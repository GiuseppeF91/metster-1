//
//  CalendarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/12))
    var yesEventsButton = SelectionButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var pendingEventsButton = SelectionButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var mapView = MKMapView(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/6)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/2))
    
    var tableView : UITableView = UITableView()
    
    var hostedEvents = []
    var pendingArray = ["No", "Comedy", "No", "Yes"]
    
    var annotationsConfirmed = [MKPointAnnotation]()
    var annotationsPending = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
      
        navigationItem.title = "Events"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        yesEventsButton.addTarget(self, action: "yesEventsClicked", forControlEvents: UIControlEvents.TouchUpInside)
        yesEventsButton.setTitle("Confirmed", forState: .Normal)
        self.view.addSubview(yesEventsButton)
        
        pendingEventsButton.addTarget(self, action: "pendingEventsClicked", forControlEvents: UIControlEvents.TouchUpInside)
        pendingEventsButton.setTitle("Pending", forState: .Normal)
        pendingEventsButton.selected = true
        self.view.addSubview(pendingEventsButton)
        
        mapView.delegate = self
        var span = MKCoordinateSpanMake(10, 10)
        var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7, longitude: -122.4), span: span)
        mapView.setRegion(region, animated: true)
        self.view.addSubview(mapView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        self.view.addSubview(self.tableView)
        
        loadMap()
        loadEvents()
    }
    
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/2-50)
    }
    
    func loadEvents() {
        let newReq : dataRequest = dataRequest()
        newReq.oper = "111002"
        newReq.emailAddress = "navimn1991@gmail.com"
        newReq.post_req()
        print("meow")
        let jsonStringAsArray = newReq.returnedInfo
        let data: NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError!
        
        do {
            let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

            let secondPart = anyObj["response"] as! String
            
            let secondPartArray = secondPart.componentsSeparatedByString(":")
            print(secondPartArray)
            print("shut")
            let hosted = secondPartArray[10]
            hosted.componentsSeparatedByString("', u'")
            
            // Split based on characters.
            hostedEvents = hosted.componentsSeparatedByString("', u'")
            print(hostedEvents)
            tableView.reloadData()
            
        } catch {
            print(error)
        }
    }
    
    func loadMap() {
        mapView.removeAnnotations(annotationsConfirmed)
        mapView.removeAnnotations(annotationsPending)
        if pendingEventsButton.selected == true {
            mapView.addAnnotations(annotationsPending)
        } else {
            mapView.addAnnotations(annotationsConfirmed)
        }
    }
    
    func pendingEventsClicked() {
        pendingEventsButton.selected = true
        yesEventsButton.selected = false
        tableView.reloadData()
        loadMap()
    }
    
    func yesEventsClicked() {
        yesEventsButton.selected = true
        pendingEventsButton.selected = false
        tableView.reloadData()
        loadMap()
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pendingEventsButton.selected == true {
            return pendingArray.count
        } else {
        return hostedEvents.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if pendingEventsButton.selected == true {
            cell.textLabel!.text = pendingArray[indexPath.row]
        } else {
            cell.textLabel!.text = hostedEvents[indexPath.row] as! String
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
        let save = UITableViewRowAction(style: .Normal, title: "Save to Events") { action, index in
            print("save button tapped")
            let newEvent = indexPath.row
            self.pendingArray.removeAtIndex(newEvent)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        save.backgroundColor = UIColor.greenColor()
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            if self.pendingEventsButton.selected == true {
                self.pendingArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            } else {
                
                // TODO : delete event from data source
               // self.hostedEvents.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        delete.backgroundColor = UIColor.grayColor()
        
        loadMap()
        
        if yesEventsButton.selected == true {
            return [delete]
        } else {
            return [delete, save]
        }
    }
}