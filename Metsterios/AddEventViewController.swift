//
//  AddEventViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import MapKit
import Haneke

class AddEventViewController: BaseVC, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var cancelButton : UIBarButtonItem!
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var inviteToList = MainLabel(frame: CGRectMake(0, (screenHeight/12)+25, screenWidth, screenHeight/15))
    var friendsTableView : UITableView = UITableView()
    
    var eventNameTextField = MainTextField(frame: CGRectMake(20, screenHeight-(screenHeight/1.2), screenWidth-40, 50))
    
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
        /*
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddEventViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(self, #selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        */

        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancelClicked))
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(AddEventViewController.nextPressed))
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = 100
        self.view.addSubview(self.friendsTableView)
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 20)) // Offset by 20 pixels vertically to take
    
        //navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        //navigationItem.title = "Search"
        /*
         let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 38, height: 38))
         imageView.contentMode = .ScaleAspectFit
         let image = UIImage(named: "bannerimg")
         imageView.image = image
         navigationItem.titleView = imageView
         */
        // Assign the navigation item to the navigation bar
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "New Event"
        navigationBar.items = [navigationItem]
        
        navBar.items = [navigationItem]
        navBar.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(navBar)
        
        inviteToList.text = "Add event members: "
        //inviteToList.attributedPlaceholder=inviteTo
        //inviteToList.delegate = self
        inviteToList.backgroundColor = UIColor.whiteColor()
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

        eventNameTextField.hidden = true
        dateLabel.hidden = true
        dateButton.hidden = true
        timeLabel.hidden = true
        timeButton.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true

    }
    
    override func viewDidLayoutSubviews() {
        friendsTableView.frame = CGRectMake(0, ((UIScreen.mainScreen().bounds.height*11)/60)+25, UIScreen.mainScreen().bounds.width, 450)
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == friendsTableView {
            count = (Users.sharedInstance().user_friends?.count)!
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        let cell = EventTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        let cache = Shared.dataCache
        cell.eventNameLabel!.text = Users.sharedInstance().user_friends![indexPath.row] as? String
            //---- cache image management
        let id = Users.sharedInstance().user_friends_id![indexPath.row]as? String

        cache.fetch(key: id!).onFailure { data in
                print ("data was not found in cache")
            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(id)/picture?type=large")
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!) { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.userImage!.image = UIImage(data: data)
                            let image : UIImage = UIImage(data: data)!
                            cache.set(value: image.asData(), key: id!)
                        })
                    }
                }
                task.resume()
        }
        
            print("check cache for image")
            cache.fetch(key: id! ).onSuccess { data in
                print ("data was found in cache")
                let image : UIImage = UIImage(data: data)!
                cell.userImage!.image = image
            }
        
            //-----

        return cell
    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //TO DO: Once the app is authorized with FB, the subfield will return user email (can be a hidden field.) This is what will be passed to Users.sharedInstance to send the invite.
        let cell = friendsTableView.cellForRowAtIndexPath(indexPath)
        print(indexPath)
        if cell?.accessoryType == . Checkmark {
            cell?.accessoryType = .None
            print(indexPath.item)
            let fid = Users.sharedInstance().user_friends_id![indexPath.row]
            invitedFriends.removeObjectIdenticalTo(fid)
        } else {
            cell?.accessoryType = .Checkmark
            print(indexPath.item)
            let fid = Users.sharedInstance().user_friends_id![indexPath.row]
            print(Users.sharedInstance().user_friends_id![indexPath.row])
            invitedFriends.addObject(fid)
        }
    }

    //MARK: Actions
    func selectDate() {
        dateBool = !dateBool
    }
    
    func selectTime() {
        timeBool = !timeBool
    }
    
    func exit() {
        print ("back pressed")
        navigationController?.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: {});
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
                //self.alertMessage("Hurray", message: "your event was created.")
                self.inviteMembers();
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                //self.findFood()
            })
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
        dateLabel.hidden = false
        dateButton.hidden = false
        timeLabel.hidden = false
        timeButton.hidden = false
        notesTextField.hidden = false
        submitButton.hidden = false
        cancelButton.enabled = false
        cancelButton.tintColor = UIColor.clearColor()
        nextButton.enabled = false
        nextButton.tintColor = UIColor.clearColor()
        backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(AddEventViewController.backPressed))
        navigationItem.leftBarButtonItem = backButton
        navBar.items = [navigationItem]
    }
    
    func cancelClicked() {
        // resets invites - removes everyone from the list.
        resetChecks()
        exit()
    }
    
    func backPressed() {
        eventNameTextField.hidden = true
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
        mapView?.hidden = true
        datePicker.hidden = true
        timePicker.hidden = true
        nextButton.tintColor = darkBlue
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
        
       print("keybord on")
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
      print("keybord off")
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}