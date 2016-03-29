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
    
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/12))
    var yesEventsButton = UIButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var pendingEventsButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var mapView = MKMapView(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/6)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/2))
    
    var tableView : UITableView = UITableView()
    
    
    var confirmedArray = ["Yes", "Japanese"]
    var pendingArray = ["No", "Comedy", "No", "Yes"]

    
    var annotationsConfirmed = [MKPointAnnotation]()
    var annotationsPending = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
        let confPin = MKPointAnnotation()
        confPin.coordinate = CLLocationCoordinate2DMake(40.730872, -74.003066)
        annotationsConfirmed.append(confPin)
        
        
        let qPin = MKPointAnnotation()
        qPin.coordinate = CLLocationCoordinate2DMake(47, -122)
        annotationsPending.append(qPin)
        

        
        
        
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        
        backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backClicked")
        
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextClicked")
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = backButton
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        yesEventsButton.addTarget(self, action: "yesEventsClicked", forControlEvents: UIControlEvents.TouchUpInside)
        yesEventsButton.setTitle("Confirmed Events", forState: .Normal)
        yesEventsButton.setTitleColor(UIColor.blackColor(), forState: .Selected)
        yesEventsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        yesEventsButton.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(yesEventsButton)
        
        pendingEventsButton.addTarget(self, action: "pendingEventsClicked", forControlEvents: UIControlEvents.TouchUpInside)
        pendingEventsButton.setTitle("Pending Events", forState: .Normal)
        pendingEventsButton.selected = true
        pendingEventsButton.setTitleColor(UIColor.blackColor(), forState: .Selected)
        pendingEventsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        pendingEventsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        pendingEventsButton.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(pendingEventsButton)
        
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
        
        loadMap()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/1.5, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/1.5)
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
    
    func backClicked() {
        
    }
    
    func nextClicked() {
        
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
        return confirmedArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if pendingEventsButton.selected == true {
            cell.textLabel!.text = pendingArray[indexPath.row]
        } else {
            cell.textLabel!.text = confirmedArray[indexPath.row]
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
                self.confirmedArray.removeAtIndex(indexPath.row)
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