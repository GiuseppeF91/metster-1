//
//  AddEventViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

//TO DO: fix date and time picker views/ resign on tap outside

class AddEventViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    var cancelButton : UIBarButtonItem!
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/12))
    var inviteToList = MainTextField(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/15))
    var friendsTableView : UITableView = UITableView()
    var nameTextField = MainTextField(frame: CGRectMake(20, 200, (UIScreen.mainScreen().bounds.width)-40, 50))
    
    var typeLabel = MainLabel(frame: CGRectMake(20, 260, (UIScreen.mainScreen().bounds.width)-40, 50))
    var typeButton = UIButton(frame: CGRectMake(20, 260, (UIScreen.mainScreen().bounds.width)-40, 50))
    
    var typePicker = UIPickerView(frame: CGRectMake(0, 500, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-500))
    var typePickerData = ["Restaurant", "Movie"]
    
    var dateLabel = MainLabel(frame: CGRectMake(20, 320, (UIScreen.mainScreen().bounds.width)-150, 50))
    var dateButton = UIButton(frame: CGRectMake(20, 320, (UIScreen.mainScreen().bounds.width)-150, 50))
    
    var datePicker = UIDatePicker(frame: CGRectMake(0, 500, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-500))

    var timeLabel = MainLabel(frame: CGRectMake(20, 380, (UIScreen.mainScreen().bounds.width)-150, 50))
    var timeButton = UIButton(frame: CGRectMake(20, 380, (UIScreen.mainScreen().bounds.width)-150, 50))
    var timePicker = UIDatePicker(frame: CGRectMake(0, 500, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-500))
 
    var notesTextField = MainTextField(frame: CGRectMake(20, 440, (UIScreen.mainScreen().bounds.width)-40, 50))
    var submitButton = SubmitButton(frame: CGRectMake(80, 555, (UIScreen.mainScreen().bounds.width)-160, 40))
    
    var whiteButton = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height-(UIScreen.mainScreen().bounds.height-500)))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelClicked")
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextPressed")
        
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        friendsTableView.rowHeight = 50
        self.view.addSubview(self.friendsTableView)
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "New Event"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        let inviteTo=NSAttributedString(string: "To:", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        inviteToList.attributedPlaceholder=inviteTo
        inviteToList.delegate = self
        inviteToList.layer.cornerRadius = 5
        self.view.addSubview(inviteToList)
        
        let name=NSAttributedString(string: "Name", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        nameTextField.attributedPlaceholder=name
        nameTextField.delegate = self
        self.view.addSubview(nameTextField)
        
        typeLabel.textAlignment = NSTextAlignment.Left
        typeLabel.text = "Type"
        self.view.addSubview(typeLabel)

        typeButton.addTarget(self, action: "selectType", forControlEvents: UIControlEvents.TouchUpInside)
        typeButton.backgroundColor = UIColor.clearColor()
        self.view.addSubview(typeButton)
        
        typePicker.dataSource = self
        typePicker.delegate = self
        self.view.addSubview(typePicker)
        typePicker.hidden = true
        typePicker.bringSubviewToFront(typePicker)
        
        dateLabel.textAlignment = NSTextAlignment.Left
        dateLabel.text = "Date"
        self.view.addSubview(dateLabel)
        
        dateButton.addTarget(self, action: "selectDate", forControlEvents: UIControlEvents.TouchUpInside)
        dateButton.backgroundColor = UIColor.clearColor()
        self.view.addSubview(dateButton)
        
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
        
        timeButton.addTarget(self, action: "selectTime", forControlEvents: UIControlEvents.TouchUpInside)
        timeButton.backgroundColor = UIColor.clearColor()
        self.view.addSubview(timeButton)
        
        timePicker.addTarget(self, action: "timePickerValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(timePicker)
        timePicker.bringSubviewToFront(timePicker)
        timePicker.hidden = true
        
        let notes=NSAttributedString(string: "Notes", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        notesTextField.attributedPlaceholder=notes
        notesTextField.delegate = self
        self.view.addSubview(notesTextField)
        
        whiteButton.backgroundColor = UIColor.clearColor()
        whiteButton.addTarget(self, action: #selector(self.removePicker), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(whiteButton)
        whiteButton.hidden = true
        
        submitButton.addTarget(self, action: #selector(self.submitPressed), forControlEvents: UIControlEvents.TouchUpInside)
        submitButton.setTitle("Submit", forState: .Normal)
        self.view.addSubview(submitButton)
        
        nameTextField.hidden = true
        typeLabel.hidden = true
        typeButton.hidden = true
        dateLabel.hidden = true
        dateButton.hidden = true
        timeLabel.hidden = true
        timeButton.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true
    }
    
    override func viewDidLayoutSubviews() {
        friendsTableView.frame = CGRectMake(0, ((UIScreen.mainScreen().bounds.height*11)/60)+25, UIScreen.mainScreen().bounds.width, 400)
    }
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        cell.textLabel!.text = "Name"
        return cell
    }
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // show check on left side, select name, show in the inviteToList
        
        let cell = friendsTableView.cellForRowAtIndexPath(indexPath)
        if cell?.accessoryType == . Checkmark {
            cell?.accessoryType = .None
        }
        else {
            cell?.accessoryType = .Checkmark
        }
    }
    
    //MARK: Picker View Data Source and Delegates
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typePickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typePickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typeLabel.text = typePickerData[row]
        typePicker.hidden = true
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }

    //MARK: Actions
    
    func selectType() {
        datePicker.hidden = true
        timePicker.hidden = true
        typePicker.hidden = false
        
        submitButton.hidden = true
        whiteButton.hidden = false
    }
    
    func selectDate() {
        typePicker.hidden = true
        timePicker.hidden = true
        datePicker.hidden = false
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        submitButton.hidden = true
        whiteButton.hidden = false
    }
    
    func selectTime() {
        datePicker.hidden = true
        typePicker.hidden = true
        timePicker.hidden = false
        
        timePicker.datePickerMode = UIDatePickerMode.Time
        submitButton.hidden = true
        whiteButton.hidden = false
    }
    
    func removePicker() {
        datePicker.hidden = true
        timePicker.hidden = true
        typePicker.hidden = true
        
        submitButton.hidden = false
        whiteButton.hidden = true
    }
    
    func submitPressed() {
        // submits event
        
        alertMessage("Congratuations", message: "You've successfully created an event")
    }
    
    func nextPressed() {
        // goes to second screen of creating event
        inviteToList.hidden = true
        friendsTableView.hidden = true
        nameTextField.hidden = false
        typeLabel.hidden = false
        typeButton.hidden = false
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
        backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backPressed")
        navigationItem.leftBarButtonItem = backButton
        navBar.items = [navigationItem]
    }
    
    func cancelClicked() {
        // resets invites - removes everyone from the list.
        
        resetChecks()
    }
    
    func backPressed() {
        nameTextField.hidden = true
        typeLabel.hidden = true
        typeButton.hidden = true
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
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}