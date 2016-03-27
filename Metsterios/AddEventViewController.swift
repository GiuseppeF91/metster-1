//
//  AddEventViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    var cancelButton : UIBarButtonItem!
    var nextButton : UIBarButtonItem!
    var backButton : UIBarButtonItem!
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, 65))
    var nameTextField = MainTextField(frame: CGRectMake(20, 200, (UIScreen.mainScreen().bounds.width)-40, 50))
    var typeTextField = MainTextField(frame: CGRectMake(20, 260, (UIScreen.mainScreen().bounds.width)-40, 50))
    var dateTextField = MainTextField(frame: CGRectMake(20, 320, (UIScreen.mainScreen().bounds.width)-150, 50))
    var timeTextField = MainTextField(frame: CGRectMake(20, 380, (UIScreen.mainScreen().bounds.width)-150, 50))
    var notesTextField = MainTextField(frame: CGRectMake(20, 440, (UIScreen.mainScreen().bounds.width)-40, 100))
    var submitButton = MainButton(frame: CGRectMake(80, 555, (UIScreen.mainScreen().bounds.width)-160, 40))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelClicked")
        nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "nextPressed")
        
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.title = "New Event"
        
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        let name=NSAttributedString(string: "Name", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        nameTextField.attributedPlaceholder=name
        nameTextField.delegate = self
        self.view.addSubview(nameTextField)
        
        let type=NSAttributedString(string: "Type of Event", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        typeTextField.attributedPlaceholder=type
        typeTextField.delegate = self
        self.view.addSubview(typeTextField)
        
        let date=NSAttributedString(string: "Date", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        dateTextField.attributedPlaceholder=date
        dateTextField.delegate = self
        self.view.addSubview(dateTextField)
        
        let time=NSAttributedString(string: "Time", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        timeTextField.attributedPlaceholder=time
        timeTextField.delegate = self
        self.view.addSubview(timeTextField)
        
        let notes=NSAttributedString(string: "Notes", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        notesTextField.attributedPlaceholder=notes
        notesTextField.delegate = self
        self.view.addSubview(notesTextField)
        
        submitButton.addTarget(self, action: "submitPressed", forControlEvents: UIControlEvents.TouchUpInside)
        submitButton.setTitle("Submit", forState: .Normal)
        self.view.addSubview(submitButton)
        
        nameTextField.hidden = true
        typeTextField.hidden = true
        dateTextField.hidden = true
        timeTextField.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true
    }
    
    func submitPressed() {
        // submits event
    }
    
    func nextPressed() {
        // goes to second screen of creating event
        
        nameTextField.hidden = false
        typeTextField.hidden = false
        dateTextField.hidden = false
        timeTextField.hidden = false
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
    }
    
    func backPressed() {
        backButton.enabled = false
        backButton.tintColor = UIColor.clearColor()
        
        nameTextField.hidden = true
        typeTextField.hidden = true
        dateTextField.hidden = true
        timeTextField.hidden = true
        notesTextField.hidden = true
        submitButton.hidden = true
        navigationItem.leftBarButtonItem = cancelButton
        cancelButton.enabled = true
        cancelButton.tintColor = UIColor.blackColor()
        nextButton.enabled = true
        nextButton.tintColor = UIColor.blackColor()
    }

}