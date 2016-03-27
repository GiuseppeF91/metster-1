//
//  LoginViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var loginButton = UIButton(frame: CGRectMake(10, 400, (UIScreen.mainScreen().bounds.width)-20, 50))
    var emailTextField = MainTextField(frame: CGRectMake(10, 280, (UIScreen.mainScreen().bounds.width)-20, 50))
    var passwordTextField = MainTextField(frame: CGRectMake(10, 340, (UIScreen.mainScreen().bounds.width)-20, 50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: "loginPressed", forControlEvents: UIControlEvents.TouchUpInside)
        loginButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        loginButton.setTitle("Sign In", forState: .Normal)
        self.view.addSubview(loginButton)
        
        let name=NSAttributedString(string: "Email", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        emailTextField.attributedPlaceholder=name
        emailTextField.delegate = self
        self.view.addSubview(emailTextField)
        
        let password=NSAttributedString(string: "Password", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        passwordTextField.attributedPlaceholder=password
        passwordTextField.secureTextEntry = true
        passwordTextField.delegate = self
        self.view.addSubview(passwordTextField)
    }
    
    func loginPressed() {
        
        let ref = Firebase(url: "https://mets.firebaseio.com")
        let email = emailTextField.text
        let password = passwordTextField.text
        
        ref.observeAuthEventWithBlock({ authData in
            if email != "" && password != "" {
                ref.authUser(email, password: password) {
                    error, authData in
                    if error != nil {
                        // an error occured while attempting login
                        self.errorAlert("Error", message: "Unable to log in")
                    } else {
                        // user is logged in, check authData for data
                        self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                    }
                }
            }
            if authData != nil {
                // user authenticated already
                print(authData)
                //Enter the app
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            } else {
                // No user is signed in
                self.errorAlert("Error", message: "Enter login credentials")
            }
        })
    }
    
    func errorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}