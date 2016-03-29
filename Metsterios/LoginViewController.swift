//
//  LoginViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var loginButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height/12)+25, UIScreen.mainScreen().bounds.width/2, (UIScreen.mainScreen().bounds.height)/12))
    var locManager = CLLocationManager()
    
    let ref = Firebase(url: "https://mets.firebaseio.com")
    let facebookLogin = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print ("not logged in")
            
        } else {
            print ("logged in")
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            })
        }

        loginButton.center = self.view.center
        loginButton.backgroundColor = UIColor.blackColor()
        loginButton.setTitle("Login with Facebook", forState: .Normal)
        loginButton.addTarget(self, action: "loginNow", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    func loginNow() {
        facebookLogin.logInWithReadPermissions(["email", "public_profile", "user_friends", "user_location", "user_photos"], fromViewController: self, handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            UserVariables.userName = authData.providerData["displayName"] as! String
                            self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                                    // Authentication just completed successfully :)
                                    // The logged in user's unique identifier
                                    print(authData.uid)
                                    // Create a new user dictionary accessing the user's info
                                    // provided by the authData parameter
                            
                            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "location"])
                            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                                
                                if ((error) != nil) {
                                    // Process error
                                    print("Error: \(error)")
                                } else {
                                    let location : NSDictionary! = result.valueForKey("location") as! NSDictionary
                                    
                                    print(location)
                                    
                                }
                            })
                        }
                        
                        let newUser = [
                            "provider": authData.provider,
                            "displayName": authData.providerData["displayName"] as? NSString as? String,
                            "email": authData.providerData["email"] as? NSString as? String
                        ]
                        
                        // Create a child path with a key set to the uid underneath the "users" node
                        // This creates a URL path like the following:
                        //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                        self.ref.childByAppendingPath("users")
                            .childByAppendingPath(authData.uid).setValue(newUser)
                })
            }
        })
        locRequest()
    }
    
    func locRequest() {
        locManager.requestAlwaysAuthorization()
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                print("lat and long")
        }
        else {
            print("no")
        }
    }
    
    //MARK: Text field delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}