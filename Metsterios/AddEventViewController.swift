//
//  AddEventViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit

class AddEventViewController: BaseVC, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var cancelButton : UIBarButtonItem!
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var inviteToList = MainLabel(frame: CGRectMake(0, (screenHeight/12)+25, screenWidth, screenHeight/15))
    var friendsTableView : UITableView = UITableView()
    var placesTableView : UITableView = UITableView()
    
    var eventNameTextField = MainTextField(frame: CGRectMake(20, screenHeight-(screenHeight/1.2), screenWidth-40, 50))
    var moviesButton = SelectionButton(frame: CGRectMake(20, 100, ((screenWidth)/2)-30, 40))
    var restaurantButton = SelectionButton(frame: CGRectMake((screenWidth/2)+10, 100, (screenWidth/2)-30, 40))
    
    var searchLabel = UILabel(frame: CGRectMake(20, screenHeight-260, screenWidth, 30))
    var myPrefLabel = UILabel(frame: CGRectMake(20, screenHeight-230, screenWidth-40, 30))
    var myPrefSwitch = UISwitch(frame: CGRectMake(screenWidth-100, screenHeight-230, 0, 0))
    var friendsPrefLabel = UILabel(frame: CGRectMake(20, screenHeight-190, screenWidth-40, 30))
    var friendsPrefSwitch = UISwitch(frame: CGRectMake(screenWidth-100, screenHeight-190, 0, 0))
    var searchQueryTextField = MainTextField(frame: CGRectMake(20, screenHeight-150, screenWidth-130, 30))
    var searchQSwitch = UISwitch(frame: CGRectMake(screenWidth-100, screenHeight-150, 0, 0))
    
    var dateLabel = MainLabel(frame: CGRectMake(20, screenHeight-(screenHeight/1.2)+60, screenWidth/4, 40))
    var dateButton = UIButton(frame: CGRectMake(20, screenHeight-(screenHeight/1.2)+60, screenWidth/4, 40))
    var datePicker = UIDatePicker(frame: CGRectMake(screenWidth/3, screenHeight-(screenHeight/1.2)+40, screenWidth/1.7, 150))
    
    var timeLabel = MainLabel(frame: CGRectMake(20, screenHeight-(screenHeight/1.2)+110, screenWidth/4, 40))
    var timeButton = UIButton(frame: CGRectMake(20, screenHeight-(screenHeight/1.2)+110, screenWidth/4, 40))
    var timePicker = UIDatePicker(frame: CGRectMake(screenWidth/3, screenHeight-(screenHeight/1.2)+40, screenWidth/1.7, 150))
    
    var notesTextField = MainTextField(frame: CGRectMake(20, screenHeight/2, screenWidth-40, 100))
    var submitButton = SubmitButton(frame: CGRectMake(80, screenHeight-100, screenWidth-160, 40))
    
    var invitedFriends : NSMutableArray = []
    var names : NSMutableArray? = []
    var images : NSMutableArray? = []
    let newValues : NSMutableArray? = []
    var dictionary = NSDictionary()
    var mapView : MKMapView?
    var annotations = [MKPointAnnotation]()
    
    var dateBool: Bool = false {
        didSet {
            if dateBool == true {
                timeBool = false
                datePicker.datePickerMode = UIDatePickerMode.Date
                datePicker.hidden = false
            }
            if dateBool == false {
                datePicker.hidden = true
            }
        }
    }
    
    var timeBool: Bool = false {
        didSet {
        if timeBool == true {
            dateBool = false
            timePicker.datePickerMode = UIDatePickerMode.Time
            timePicker.hidden = false
            
            }
            if timeBool == false {
                timePicker.hidden = true
            }
            if (timeBool == false) && (dateBool == false) {
                datePicker.hidden = true
                timePicker.hidden = true
            }
        }
    }
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("====== ENTER ADD EVENT View Controller =====")
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        

        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancelClicked))
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(AddEventViewController.nextPressed))
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = 50
        self.view.addSubview(self.friendsTableView)
        
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.rowHeight = 100
        self.view.addSubview(self.placesTableView)
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "New Event"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        inviteToList.text = "invite:"
        //inviteToList.attributedPlaceholder=inviteTo
        //inviteToList.delegate = self
        inviteToList.backgroundColor = UIColor.grayColor()
        inviteToList.layer.cornerRadius = 5
        self.view.addSubview(inviteToList)
        
        let name=NSAttributedString(string: "Event Name", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        eventNameTextField.attributedPlaceholder=name
        eventNameTextField.delegate = self
        self.view.addSubview(eventNameTextField)
        
        dateButton.addTarget(self, action: #selector(self.selectDate), forControlEvents: UIControlEvents.TouchUpInside)
        dateButton.backgroundColor = UIColor.clearColor()
        self.view.addSubview(dateButton)
        dateButton.selected = false
        
        datePicker.bringSubviewToFront(datePicker)
        let currentDate = NSDate()
        datePicker.minimumDate = currentDate
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(AddEventViewController.datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(datePicker)
        datePicker.hidden = true
        
        dateLabel.textAlignment = NSTextAlignment.Left
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let dateValue = dateformatter.stringFromDate(datePicker.date)
        dateLabel.text = dateValue
        dateLabel.text = String(dateValue)
        self.view.addSubview(dateLabel)

        timeLabel.textAlignment = NSTextAlignment.Left
        let timeformatter = NSDateFormatter()
        timeformatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeValue = timeformatter.stringFromDate(timePicker.date)
        timeLabel.text = String(timeValue)
        self.view.addSubview(timeLabel)
        
        timeButton.addTarget(self, action: #selector(AddEventViewController.selectTime), forControlEvents: UIControlEvents.TouchUpInside)
        timeButton.backgroundColor = UIColor.clearColor()
        self.view.addSubview(timeButton)
        timeButton.selected = false
        
        timePicker.addTarget(self, action: #selector(AddEventViewController.timePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(timePicker)
        timePicker.bringSubviewToFront(timePicker)
        timePicker.hidden = true
        
        let notes=NSAttributedString(string: "Notes", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        notesTextField.attributedPlaceholder=notes
        notesTextField.delegate = self
        self.view.addSubview(notesTextField)
    
        submitButton.addTarget(self, action: #selector(self.newEventCreated), forControlEvents: UIControlEvents.TouchUpInside)
        submitButton.setTitle("Submit", forState: .Normal)
        self.view.addSubview(submitButton)
        
        moviesButton.addTarget(self, action: #selector(self.moviesClicked), forControlEvents: UIControlEvents.TouchUpInside)
        let selectedMovieFontTitle = NSAttributedString(string: "Movie", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
        let deselectedMovieFontTitle = NSAttributedString(string: "Movie", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)])
        moviesButton.setAttributedTitle(selectedMovieFontTitle, forState: .Selected)
        moviesButton.setAttributedTitle(deselectedMovieFontTitle, forState: .Normal)
        self.view.addSubview(moviesButton)
        moviesButton.selected = false
        moviesButton.enabled = false
        
        restaurantButton.addTarget(self, action: #selector(self.restaurantClicked), forControlEvents: UIControlEvents.TouchUpInside)
        let selectedFoodFontTitle = NSAttributedString(string: "Restaurant", attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
        let deselectedFoodFontTitle = NSAttributedString(string: "Restaurant", attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15)])
        restaurantButton.setAttributedTitle(selectedFoodFontTitle, forState: .Selected)
        restaurantButton.setAttributedTitle(deselectedFoodFontTitle, forState: .Normal)
        self.view.addSubview(restaurantButton)
        restaurantButton.selected = true
        
        eventNameTextField.hidden = true
        moviesButton.hidden = true
        restaurantButton.hidden = true
        dateLabel.hidden = true
        dateButton.hidden = true
        timeLabel.hidden = true
        timeButton.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true
        searchQueryTextField.hidden = true
        searchLabel.hidden = true
        myPrefSwitch.hidden = true
        myPrefLabel.hidden = true
        friendsPrefLabel.hidden = true
        friendsPrefSwitch.hidden = true
        
        placesTableView.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        friendsTableView.frame = CGRectMake(0, ((UIScreen.mainScreen().bounds.height*11)/60)+25, UIScreen.mainScreen().bounds.width, 400)
        placesTableView.frame = CGRectMake(0, screenHeight/2, screenWidth, (screenHeight/2)-50)
    }

    func moviesClicked() {
        restaurantButton.selected = false
        moviesButton.selected = true
    }
    
    func restaurantClicked() {
        moviesButton.selected = false
        restaurantButton.selected = true
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == friendsTableView {
            count = (Users.sharedInstance().user_friends?.count)!
        }
        if tableView == placesTableView  {
            if Users.sharedInstance().places == nil {
                count = 0
            } else {
                count = Users.sharedInstance().places!.count
            }
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        let cell = EventTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        if tableView == friendsTableView {
            cell.textLabel!.text = Users.sharedInstance().user_friends![indexPath.row] as? String
        }
        if tableView == placesTableView && Users.sharedInstance().places != nil {
            
            for item in newValues! {
                let newName = item.valueForKey("name")
                self.names?.addObject(newName!)
                
                let newImage = item.valueForKey("image_url")
                
                
                self.images?.addObject(newImage!)
            }
            Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            cell.eventNameLabel!.text = names![indexPath.row] as? String
    
            let url = NSURL(string: images![indexPath.row] as! String)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.userImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
        }
        return cell
    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //TO DO: Once the app is authorized with FB, the subfield will return user email (can be a hidden field.) This is what will be passed to Users.sharedInstance to send the invite. 
        if tableView == friendsTableView {
            let cell = friendsTableView.cellForRowAtIndexPath(indexPath)
            if cell?.accessoryType == . Checkmark {
                cell?.accessoryType = .None
                invitedFriends.removeObjectIdenticalTo(cell!.textLabel!.text!)
            }
            else {
                cell?.accessoryType = .Checkmark
                invitedFriends.addObject(cell!.textLabel!.text!)
            }
        }
        if tableView == placesTableView {
            //TO DO : send correct parameters throught to req 997000 aka func pickedLocation() 
            
            Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            print(Users.sharedInstance().place_id)
            let item = newValues![indexPath.row]

            dictionary = ["category": item.valueForKey("category")!, "ratings": item.valueForKey("ratings")!, "review_count": item.valueForKey("review_count")!, "name": item.valueForKey("name")!, "latitude": item.valueForKey("latitude")!, "url": "www.yelp.com", "rank": item.valueForKey("rank")!, "snippet": item.valueForKey("snippet")!, "phone": item.valueForKey("phone")!, "image_url": item.valueForKey("image_url")!, "longitude" : item.valueForKey("longitude")!, "address": item.valueForKey("address")!, "coordinate": item.valueForKey("coordinate")!, "eventid": Users.sharedInstance().event_id!, "eventname": Users.sharedInstance().eventName!, "eventdate": Users.sharedInstance().event_date!, "eventtime": Users.sharedInstance().event_time!]
            
            print(dictionary)
            
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.init(rawValue: 0))
            let myString = String(data: jsonData, encoding: NSUTF8StringEncoding)
    
            Users.sharedInstance().place_info = myString
        
            let alert = UIAlertController(title: "Save Event Location", message: "Is this the location you want to save?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
                    
                    RequestInfo.sharedInstance().postReq("997000")
                    { (success, errorString) -> Void in
                        guard success else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.alertMessage("Error", message: "Unable to connect.")
                            })
                            return
                        }
                        dispatch_async(dispatch_get_main_queue(), {
                            print("suucssssss")
                            //self.alertMessage("Success!", message: "Event Saved")
                            self.inviteMembers()
                            self.placesTableView.hidden = true
                            self.mapView?.hidden = true
                            self.performSegueWithIdentifier("MapViewController", sender:self)
                        })
                    }
                }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    //MARK: Actions
    func selectDate() {
        dateBool = !dateBool
    }
    
    func selectTime() {
        timeBool = !timeBool
    }
    
    func myPref() {
        myPrefSwitch.on = true
        friendsPrefSwitch.on = false
        searchQSwitch.on = false
    }
    
    func friendPref() {
        myPrefSwitch.on = false
        friendsPrefSwitch.on = true
        searchQSwitch.on = false
    }
    
    func customPref() {
        myPrefSwitch.on = false
        friendsPrefSwitch.on = false
        searchQSwitch.on = true
    }
    
    func newEventCreated() {
        activityIndicator.startAnimating()
        //Inserts Event
        Users.sharedInstance().eventName = eventNameTextField.text
        Users.sharedInstance().event_date = dateLabel.text
        Users.sharedInstance().event_time = timeLabel.text
        Users.sharedInstance().event_notes = notesTextField.text
        Users.sharedInstance().invited_members = invitedFriends
        timeBool = false
        dateBool = false 
        

        RequestInfo.sharedInstance().postReq("121000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Unable to make the event")
                    self.alertMessage("Error", message: "Unable to connect.")
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("suucessssss")
                self.findFood()
            })
        }
    }
    
    func findFood() {

        newValues?.removeAllObjects()
        names?.removeAllObjects()
        images?.removeAllObjects()
        
        
        Users.sharedInstance().query = "go_with_group"
        
        RequestInfo.sharedInstance().postReq("999000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at getting foodz")
                    self.alertMessage("Error", message: "Unable to connect.")
                })
                return
            }
            
            dispatch_after(self.popTime, self.GlobalMainQueue) {
              
                for item in Users.sharedInstance().places! {
                    print(Users.sharedInstance().place_id)
                    let restaurantData : NSData = (item.dataUsingEncoding(NSUTF8StringEncoding))!
                    
                    do {
                        let restaurantInfo = try NSJSONSerialization.JSONObjectWithData(restaurantData , options: .AllowFragments) as! NSMutableDictionary
                        self.newValues!.addObject(restaurantInfo)
                    } catch {
                        print(error)
                    }
                }

                self.loadMap()
                self.eventNameTextField.hidden = true
                self.moviesButton.hidden = true
                self.restaurantButton.hidden = true
                self.dateLabel.hidden = true
                self.dateButton.hidden = true
                self.timeLabel.hidden = true
                self.timeButton.hidden = true
                self.notesTextField.hidden = true
                self.submitButton.hidden = true
                self.searchQueryTextField.hidden = true
                self.searchQSwitch.hidden = true
                self.searchLabel.hidden = true
                self.myPrefSwitch.hidden = true
                self.myPrefLabel.hidden = true
                self.friendsPrefLabel.hidden = true
                self.friendsPrefSwitch.hidden = true
                self.timePicker.hidden = true
                self.datePicker.hidden = true

                print("Found restauants!")
                self.placesTableView.hidden = false
                print(Users.sharedInstance().places)
                self.placesTableView.reloadData()
            }
        }
    }
    
    func loadMap() {
        mapView = MKMapView(frame: CGRectMake(0, screenHeight/8, screenWidth, screenHeight/2.8))
        mapView?.delegate = self
        let span = MKCoordinateSpanMake(4, 4)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 38.5, longitude: -121.4), span: span)
        mapView?.zoomEnabled = true
        mapView?.scrollEnabled = true
        mapView?.setRegion(region, animated: true)
        self.view.addSubview(mapView!)
        view.bringSubviewToFront(friendsTableView)
        for value in newValues! {
            let latitude = Double(value.valueForKey("latitude") as! String)
            let longitude = Double(value.valueForKey("longitude") as! String)
            print(latitude)
            print(longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            annotation.title = value.valueForKey("name") as? String
            annotation.subtitle = value.valueForKey("address") as? String
            self.annotations.removeAll()
            self.annotations.append(annotation)
            mapView!.addAnnotations(self.annotations)
            activityIndicator.stopAnimating()
        }
    }
    
    func inviteMembers() { // invites are sent via 998001
        
        for friend in invitedFriends {
            Users.sharedInstance().invited_members = friend
            print(friend)
            RequestInfo.sharedInstance().postReq("998001")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                        self.alertMessage("Error", message: "Unable to connect.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Success!", message: "Event Created")
                })
            }
        }
    }

    func nextPressed() {
        // goes to second screen of creating event
        inviteToList.hidden = true
        friendsTableView.hidden = true
        eventNameTextField.hidden = false
        //restaurantButton.hidden = false
        //moviesButton.hidden = false
        dateLabel.hidden = false
        dateButton.hidden = false
        timeLabel.hidden = false
        timeButton.hidden = false
        notesTextField.hidden = false
        submitButton.hidden = false
        cancelButton.enabled = false
        cancelButton.tintColor = UIColor.clearColor()
        nextButton.enabled = false
        searchQueryTextField.hidden = false
        searchLabel.hidden = false
        myPrefSwitch.hidden = false
        myPrefLabel.hidden = false
        searchQSwitch.hidden = false
        friendsPrefLabel.hidden = false
        friendsPrefSwitch.hidden = false
        nextButton.tintColor = UIColor.clearColor()
        backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(AddEventViewController.backPressed))
        navigationItem.leftBarButtonItem = backButton
        navBar.items = [navigationItem]
    }
    
    func cancelClicked() {
        // resets invites - removes everyone from the list.
        resetChecks()
    }
    
    func backPressed() {
        eventNameTextField.hidden = true
        restaurantButton.hidden = true
        moviesButton.hidden = true
        dateLabel.hidden = true
        dateButton.hidden = true
        timeLabel.hidden = true
        timeButton.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true
        inviteToList.hidden = false
        friendsTableView.hidden = false
        backButton.enabled = false
        backButton.tintColor = UIColor.clearColor()
        navigationItem.leftBarButtonItem = cancelButton
        cancelButton.enabled = true
        cancelButton.tintColor = UIColor.blackColor()
        nextButton.enabled = true
        searchLabel.hidden = true
        searchQSwitch.hidden = true
        searchQueryTextField.hidden = true
        friendsPrefSwitch.hidden = true
        friendsPrefLabel.hidden = true
        myPrefLabel.hidden = true
        myPrefSwitch.hidden = true
        mapView?.hidden = true
        datePicker.hidden = true
        timePicker.hidden = true
        nextButton.tintColor = darkBlue
        placesTableView.hidden = true
    }
    
    //MARK : helpers
    func datePickerValueChanged() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let dateValue = dateformatter.stringFromDate(datePicker.date)
        dateLabel.text = dateValue 
    }
    
    func timePickerValueChanged() {
        let dateformatter = NSDateFormatter()
        dateformatter.timeStyle = NSDateFormatterStyle.ShortStyle
        let timeValue = dateformatter.stringFromDate(timePicker.date)
        timeLabel.text = timeValue
    }
    
    func resetChecks() {
        for i in 0...friendsTableView.numberOfSections-1
        {
            for j in 0...friendsTableView.numberOfRowsInSection(i)-1
            {
                if let cell = friendsTableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    cell.accessoryType = .None
                }
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if searchQueryTextField.editing == true {
            submitButton.enabled = false
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if searchQueryTextField.editing == true{
            submitButton.enabled = true 
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}