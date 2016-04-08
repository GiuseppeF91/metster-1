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
    
    var lettersArray = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l" ]
    var moviesArray = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Horror", "Romance", "Sci-fi", "Thriller", "War"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        moviesButton.addTarget(self, action: #selector(PreferencesViewController.moviesClicked), forControlEvents: UIControlEvents.TouchUpInside)
        moviesButton.setTitle("Movies", forState: .Normal)
        self.view.addSubview(moviesButton)
        
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
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return false
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restaurantButton.selected == true {
            return lettersArray.count
        } else {
            return moviesArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        if restaurantButton.selected == true {
            
            //Once all user prefs are saved correctly, the lettersArray can be deleted. Users.sharedInstance().food_pref can be loaded instead after server req 111002, on home screen. 

            let item = lettersArray[indexPath.row]
    
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
        let itemToMove = lettersArray[fromIndexPath.row]
        lettersArray.removeAtIndex(fromIndexPath.row)
        lettersArray.insert(itemToMove, atIndex: toIndexPath.row)
        
        print(lettersArray)
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
            Users.sharedInstance().food_pref = lettersArray
            print(Users.sharedInstance().food_pref)
            //Users.sharedInstance().what = "food_pref"
            //print(Users.sharedInstance().food_pref)
        }
      
        if moviesButton.selected == true {
           // Users.sharedInstance().movie_pref = new_movie_pref
            Users.sharedInstance().what = "movie_pref"
        }
        
       /* RequestInfo.sharedInstance().postReq("111003")
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
        } */
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
