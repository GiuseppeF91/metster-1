//
//  BaseVC.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/2/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

var screenWidth = UIScreen.mainScreen().bounds.width
var screenHeight = UIScreen.mainScreen().bounds.height
var lightBlue = UIColor(red:97.0/255.0, green:200.0/255.0, blue:255.0/255.0, alpha:1.0)
var darkBlue = UIColor(red:39.0/255.0, green:40.0/255.0, blue:81.0/255.0, alpha:1.0)

class BaseVC: UIViewController, UITextFieldDelegate {
    
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, screenWidth, screenHeight/12))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.backgroundColor = lightBlue
        navBar.tintColor = darkBlue
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        activityIndicator.center = view.center
        self.view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    //MARK: Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
