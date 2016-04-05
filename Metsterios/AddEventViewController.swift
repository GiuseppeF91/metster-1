//
//  AddEventViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class AddEventViewController: BaseVC, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    var cancelButton : UIBarButtonItem!
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var inviteToList = MainLabel(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/15))
    var friendsTableView : UITableView = UITableView()
    var eventNameTextField = MainTextField(frame: CGRectMake(20, 200, (UIScreen.mainScreen().bounds.width)-40, 50))
    
    var moviesButton = SelectionButton(frame: CGRectMake(20, 260, ((UIScreen.mainScreen().bounds.width)/2)-30, 50))
    var restaurantButton = SelectionButton(frame: CGRectMake(((UIScreen.mainScreen().bounds.width)/2)+10, 260, ((UIScreen.mainScreen().bounds.width)/2)-30, 50))
    
    var dateLabel = MainLabel(frame: CGRectMake(20, 320, (UIScreen.mainScreen().bounds.width)-150, 50))
    var dateButton = UIButton(frame: CGRectMake(20, 320, (UIScreen.mainScreen().bounds.width)-150, 50))
    var datePicker = UIDatePicker(frame: CGRectMake(20, 370, UIScreen.mainScreen().bounds.width-40, 150))

    var timeLabel = MainLabel(frame: CGRectMake(20, 380, (UIScreen.mainScreen().bounds.width)-150, 50))
    var timeButton = UIButton(frame: CGRectMake(20, 380, (UIScreen.mainScreen().bounds.width)-150, 50))
    var timePicker = UIDatePicker(frame: CGRectMake(20, 430, UIScreen.mainScreen().bounds.width-40, 150))
 
    var notesTextField = MainTextField(frame: CGRectMake(20, 440, (UIScreen.mainScreen().bounds.width)-40, 50))
    var submitButton = SubmitButton(frame: CGRectMake(80, 555, (UIScreen.mainScreen().bounds.width)-160, 40))
    
    var invitedFriends : NSMutableArray = []
    
    
    var dateBool: Bool = false {
        didSet {
            if dateBool == true {
                timeBool = false
                notesTextField.hidden = true
                submitButton.hidden = true
                datePicker.datePickerMode = UIDatePickerMode.Date
                datePicker.hidden = false
                timeButton.hidden = true
                timeLabel.hidden = true
            }
            if dateBool == false {
                datePicker.hidden = true
                notesTextField.hidden = false
                submitButton.hidden = false
                timeLabel.hidden = false
                timeButton.hidden = false
            }
        }
    }
    
    var timeBool: Bool = false {
        didSet {
        if timeBool == true {
            dateBool = false
            notesTextField.hidden = true
            submitButton.hidden = true
            timePicker.datePickerMode = UIDatePickerMode.Time
            timePicker.hidden = false
            timeButton.hidden = false
            timeLabel.hidden = false
            
            }
            if timeBool == false {
                timePicker.hidden = true
            }
            if (timeBool == false) && (dateBool == false) {
                datePicker.hidden = true
                timePicker.hidden = true
                submitButton.hidden = false
                notesTextField.hidden = false
                timeButton.hidden = false
                timeLabel.hidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(self.cancelClicked))
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(AddEventViewController.nextPressed))
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = 50
        self.view.addSubview(self.friendsTableView)
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "New Event"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        inviteToList.text = "To:"
        //inviteToList.attributedPlaceholder=inviteTo
        //inviteToList.delegate = self
        inviteToList.layer.cornerRadius = 5
        self.view.addSubview(inviteToList)
        
        let name=NSAttributedString(string: "Event Name", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        eventNameTextField.attributedPlaceholder=name
        eventNameTextField.delegate = self
        self.view.addSubview(eventNameTextField)
        
        dateLabel.textAlignment = NSTextAlignment.Left
        dateLabel.text = "Date"
        self.view.addSubview(dateLabel)
        
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

        timeLabel.textAlignment = NSTextAlignment.Left
        timeLabel.text = "Time"
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
        
        print(Users.sharedInstance().email)
    }
    
    override func viewDidLayoutSubviews() {
        friendsTableView.frame = CGRectMake(0, ((UIScreen.mainScreen().bounds.height*11)/60)+25, UIScreen.mainScreen().bounds.width, 400)
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
        return (Users.sharedInstance().user_friends?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        cell.textLabel!.text = Users.sharedInstance().user_friends![indexPath.row] as? String
        return cell
    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //TO DO: Once the app is authorized with FB, the subfield will return user email (can be a hidden field.) This is what will be passed to Users.sharedInstance to send the invite. 
        
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

    //MARK: Actions
    func selectDate() {
        dateBool = !dateBool
    }
    
    func selectTime() {
        timeBool = !timeBool
    }
    
    func newEventCreated() {
        //Inserts Event
        Users.sharedInstance().eventName = eventNameTextField.text
        Users.sharedInstance().event_date = dateLabel.text
        Users.sharedInstance().event_time = timeLabel.text
        Users.sharedInstance().event_notes = notesTextField.text
        Users.sharedInstance().invited_members = ["green@green.com", "jessi.gui@gmail.com"]
        
        print(Users.sharedInstance().eventName)
        print(Users.sharedInstance().event_date)
        print(Users.sharedInstance().event_time)
        print(Users.sharedInstance().event_notes)
        print(Users.sharedInstance().invited_members)
        print(Users.sharedInstance().email)

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
        Users.sharedInstance().query = Users.sharedInstance().food_pref
        
        RequestInfo.sharedInstance().postReq("999000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at getting foodz")
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("Found restauants!")
            })
        }
    }
    
    func chooseEventLocation() {
        // 999000 find food... the first location is saved and 997000 pushes to firebase
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
                self.alertMessage("Event Created!", message: "")
                RequestInfo.sharedInstance().postReq("997000")
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
                        self.inviteMembers()
                    })
                }
            })
        }
    }
    
    func inviteMembers() { // invites are sent via 998001
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

    func nextPressed() {
        // goes to second screen of creating event
        inviteToList.hidden = true
        friendsTableView.hidden = true
        eventNameTextField.hidden = false
        restaurantButton.hidden = false
        moviesButton.hidden = false
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
        nextButton.tintColor = UIColor.blackColor()
    }
    
    //MARK : helpers
    func datePickerValueChanged() {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        let dateValue = dateformatter.stringFromDate(datePicker.date)
        dateLabel.text = dateValue 
    }
    
    func timePickerValueChanged() {
        let dateformatter = NSDateFormatter()
        dateformatter.timeStyle = NSDateFormatterStyle.MediumStyle
        let timeValue = dateformatter.stringFromDate(datePicker.date)
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
}