//
//  PreferencesViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class PreferencesViewController: BaseVC, UITableViewDataSource, UITableViewDelegate {
    
    var saveButton : UIBarButtonItem!
    var reorderButton : UIBarButtonItem!
    var restaurantButton = SelectionButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    
    var moviesButton = SelectionButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var usernameLabel = UILabel(frame: CGRectMake(10, 360, (UIScreen.mainScreen().bounds.width)-20, 40))
    
    var tableView : UITableView = UITableView()
    
    var moviesArray = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Horror", "Romance", "Sci-fi", "Thriller", "War"]
    
    var food_pref : String?
    var food_array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("====== ENTER PREFERENCE View Controller =====")
        saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(PreferencesViewController.saveClicked))
        reorderButton =  UIBarButtonItem(title: "Reorder", style: .Plain, target: self, action: #selector(self.reorderItems))
        
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = reorderButton
        navigationItem.title = "Preferences"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        restaurantButton.addTarget(self, action: #selector(PreferencesViewController.restaurantClicked), forControlEvents: UIControlEvents.TouchUpInside)
        restaurantButton.setTitle("Restaurants", forState: .Normal)
        restaurantButton.selected = true
        self.view.addSubview(restaurantButton)
        restaurantButton.hidden = false
        
        moviesButton.addTarget(self, action: #selector(PreferencesViewController.moviesClicked), forControlEvents: UIControlEvents.TouchUpInside)
        moviesButton.setTitle("Movies", forState: .Normal)
        self.view.addSubview(moviesButton)
        moviesButton.hidden = false
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        self.view.addSubview(self.tableView)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, ((screenHeight*11)/60)+25, screenWidth, screenHeight-200)
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return false
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restaurantButton.selected == true {
            return 12
        } else {
            return moviesArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if restaurantButton.selected == true {
            //TO DO: List food_array in the saved order
            
            //food_pref = Users.sharedInstance().food_pref as? String
            //food_array = food_pref!.characters.map { String($0) }
            //food_array = [Character](food_pref!.characters)
            food_pref = Users.sharedInstance().food_pref as? String
            
            let item = food_array[indexPath.row]
            
            if item == "a" {
                cell.textLabel!.text = "American"
            }
            if item == "b" {
                cell.textLabel!.text = "British"
            }
            if item == "c" {
                cell.textLabel!.text  = "Chinese"
            }
            if item == "d" {
                cell.textLabel!.text  = "Greek"
            }
            if item == "e" {
                cell.textLabel!.text  = "French"
            }
            if item == "f" {
                cell.textLabel!.text  = "Indian"
            }
            if item == "g" {
                cell.textLabel!.text  = "Italian"
            }
            if item == "h" {
                cell.textLabel!.text  = "Japanese"
            }
            if item == "i" {
                cell.textLabel!.text  = "Mediterranean"
            }
            if item == "j" {
                cell.textLabel!.text = "Mexican"
            }
            if item == "k" {
                cell.textLabel!.text  = "Thai"
            }
            if item == "l" {
                cell.textLabel!.text  = "Vietnamese"
            }
            
        } else {
            cell.textLabel!.text = moviesArray[indexPath.row]
        }
        return cell
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let itemToMove = food_array[fromIndexPath.row]
        food_array.removeAtIndex(fromIndexPath.row)
        food_array.insert(itemToMove, atIndex: toIndexPath.row)
        print(food_array)
    }
    
    func reorderItems() {
        if(tableView.editing == true) {
            tableView.setEditing(false, animated: true)

        } else {
            tableView.setEditing(true, animated: true)
        }
    }

    func saveClicked() {
        if restaurantButton.selected == true {
            
            let lettersString  = food_array.joinWithSeparator("")
            Users.sharedInstance().food_pref = lettersString
            print(Users.sharedInstance().food_pref)
            Users.sharedInstance().what = "food_pref"
            tableView.setEditing(false, animated: true)
            
            RequestInfo.sharedInstance().postReq("111003")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                        self.alertMessage("Error", message: "Unable to update.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Preference Saved!", message: "")
                })
            }
        }
      
        if moviesButton.selected == true {
           // Users.sharedInstance().movie_pref = new_movie_pref
            Users.sharedInstance().what = "movie_pref"
        }
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
}
