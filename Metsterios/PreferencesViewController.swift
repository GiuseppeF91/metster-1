//
//  PreferencesViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var saveButton : UIBarButtonItem!
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/12))
    var restaurantButton = UIButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var moviesButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var usernameLabel = UILabel(frame: CGRectMake(10, 360, (UIScreen.mainScreen().bounds.width)-20, 40))
    
    var tableView : UITableView = UITableView()
    
    var foodArray = ["Chinese", "Japanese", "Mexican", "Italian", "French", "Indian"]
    var moviesArray = ["Horror", "Comedy", "Drama", "Romance", "Kids"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        
        saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveClicked")
        
        navigationItem.rightBarButtonItem = saveButton
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        restaurantButton.addTarget(self, action: "restaurantClicked", forControlEvents: UIControlEvents.TouchUpInside)
        restaurantButton.setTitle("Restaurants", forState: .Normal)
        restaurantButton.setTitleColor(UIColor.blackColor(), forState: .Selected)
        restaurantButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        restaurantButton.backgroundColor = UIColor.whiteColor()
        restaurantButton.selected = true
        self.view.addSubview(restaurantButton)
        
        moviesButton.addTarget(self, action: "moviesClicked", forControlEvents: UIControlEvents.TouchUpInside)
        moviesButton.setTitle("Movies", forState: .Normal)
        moviesButton.setTitleColor(UIColor.blackColor(), forState: .Selected)
        moviesButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        moviesButton.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(moviesButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, ((UIScreen.mainScreen().bounds.height*11)/60)+25, UIScreen.mainScreen().bounds.width, 400)
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restaurantButton.selected == true {
            return foodArray.count
        } else {
            return moviesArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if restaurantButton.selected == true {
        cell.textLabel!.text = foodArray[indexPath.row]
        } else {
            cell.textLabel!.text = moviesArray[indexPath.row]
        }
        return cell
    }
    
    // Determine whether a given row is eligible for reordering or not.
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    // Process the row move. This means updating the data model to correct the item indices.
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
        if restaurantButton.selected == true {
        let item : String = foodArray[sourceIndexPath.row]
        foodArray.removeAtIndex(sourceIndexPath.row);
        foodArray.insert(item, atIndex: destinationIndexPath.row)
        } else {
            let item : String = moviesArray[sourceIndexPath.row]
            moviesArray.removeAtIndex(sourceIndexPath.row);
            moviesArray.insert(item, atIndex: destinationIndexPath.row)
        }
    }

    func saveClicked() {
        alertMessage("Preference Saved!", message: "")
    }
    
    func restaurantClicked() {
        restaurantButton.selected = true
        moviesButton.selected = false
        tableView.reloadData()
    }
    
    func moviesClicked() {
        moviesButton.selected = true
        restaurantButton.selected = false
        tableView.reloadData()
    }
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

}
