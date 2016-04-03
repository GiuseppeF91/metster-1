//
//  LoginViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import CoreLocation
import Firebase

class LoginViewController: BaseVC, CLLocationManagerDelegate, FBSDKLoginButtonDelegate {
    
    var loginButton = SubmitButton(frame: CGRectMake(10, 100, UIScreen.mainScreen().bounds.width-20, (UIScreen.mainScreen().bounds.height)/12))
    
    var locManager = CLLocationManager()
    var currentLocation : CLLocation!
    var currentLat = ""
    var currentLong = ""
    var error : NSError?
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com/")
    let facebookLogin = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["email", "public_profile", "user_friends", "user_location", "user_photos"]
        loginView.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
                self.returnUserData()
            
                self.returnUserFriends()
        } else {
            print("not logged in")
        }
    }
    
    // Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
            print(ErrorType)
        }
        if result.isCancelled {
            // Handle cancellations
            print(ErrorType)
        }
        else {
            self.activityIndicator.startAnimating()
            //Start Location Auth
            self.locManager.requestAlwaysAuthorization()
            self.locManager.startUpdatingLocation()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.returnUserData()
                Users.sharedInstance().lat = ""
                Users.sharedInstance().long = ""
                
                //Req to 11002 (find in account) by email. IF success present VC. IF fail, Req to 111000, present VC.
                
                self.findAccount(Users.sharedInstance().email as! String)
                self.activityIndicator.startAnimating()
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    func returnUserFriends() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: ["fields": "name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            //TO DO: THIS NEEDS TO BE IMPLEMENTED TO RETURN ONLY AUTHORIZED APP USERS. Also needs to return the EMAILS of each listed user.
            if error == nil {
                print("Friends are : \(result)")
                print("OKOKOKOKOKOKOK")
                let data = result.valueForKey("data")
                print(data?.valueForKey("email"))
                Users.sharedInstance().user_friends = data?.valueForKey("name")
            } else {
                print("Error Getting Friends \(error)");
            }
        })
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                Users.sharedInstance().name = result.valueForKey("name") as! NSString
                print("User Name is: \(Users.sharedInstance().name)")
                Users.sharedInstance().email = result.valueForKey("email") as! NSString
                
                Users.sharedInstance().fbid = result.valueForKey("id") as! NSString
                
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                
            }
        })
    }

    func createAccount() {
        RequestInfo.sharedInstance().postReq("111000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at account creation.")
                    self.alertMessage("Error", message: "Your Account Info Was Not Saved.")
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("account is hereeeee")
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            })
        }
    }

    func findAccount(email: String) {
        RequestInfo.sharedInstance().postReq("111002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("didn't find account")
                    self.createAccount()
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                print("This user exists")
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            })
        }
    }
    
    func locRequest() {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
            currentLocation = locManager.location
            
        } else {
            print("no")
        }
    }
}