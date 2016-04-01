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
    var restaurantButton = SelectionButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var moviesButton = SelectionButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var usernameLabel = UILabel(frame: CGRectMake(10, 360, (UIScreen.mainScreen().bounds.width)-20, 40))
    
    var tableView : UITableView = UITableView()
    
    var foodArray = ["Chinese", "French", "Indian", "Italian", "Japanese", "Mexican"]
    var moviesArray = ["Horror", "Comedy", "Drama", "Romance"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        
        saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(PreferencesViewController.saveClicked))
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = "Preferences"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        restaurantButton.addTarget(self, action: #selector(PreferencesViewController.restaurantClicked), forControlEvents: UIControlEvents.TouchUpInside)
        restaurantButton.setTitle("Restaurants", forState: .Normal)
        restaurantButton.selected = true
        self.view.addSubview(restaurantButton)
        
        moviesButton.addTarget(self, action: #selector(PreferencesViewController.moviesClicked), forControlEvents: UIControlEvents.TouchUpInside)
        moviesButton.setTitle("Movies", forState: .Normal)
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
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // show check on left side, select name, show in the inviteToList
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == . Checkmark {
            cell?.accessoryType = .None
        }
        else {
            cell?.accessoryType = .Checkmark
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
