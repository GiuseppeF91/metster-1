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

class LoginViewController: BaseVC, CLLocationManagerDelegate {
    
    var loginButton = SubmitButton(frame: CGRectMake(10, 100, UIScreen.mainScreen().bounds.width-20, (UIScreen.mainScreen().bounds.height)/12))
    
    var locManager = CLLocationManager()
    var currentLocation : CLLocation!
    var currentLat = ""
    var currentLong = ""
    var error : NSError?
    
    let ref = Firebase(url: "https://mets.firebaseio.com")
    let facebookLogin = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print ("not logged in to fb")
            loginButton.center = self.view.center
            loginButton.setTitle("Login with Facebook", forState: .Normal)
            loginButton.addTarget(self, action: #selector(LoginViewController.loginNow), forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(loginButton)
            
        } else {
            dispatch_async(dispatch_get_main_queue(), {
            print ("logged in to fb")
            self.gotoApp()
            })
        }
    }
    
    func gotoApp() {
        presentViewController(TabBarViewController(), animated: true, completion: nil)
        //self.dismissViewControllerAnimated(true, completion: nil)
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
                self.gotoApp()

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
                self.gotoApp()
            })
        }
    }
    
    func loginNow() {
        facebookLogin.logInWithReadPermissions(["email", "public_profile", "user_friends", "user_location", "user_photos"], fromViewController: self, handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                //firebase auth for user info
                dispatch_async(dispatch_get_main_queue(), {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            print("Logged in firebase ! \(authData)")
                            
                            // Authentication just completed successfully
                            // The logged in user's unique identifier
                
                            Users.sharedInstance().name = authData.providerData["displayName"] as! String
                            Users.sharedInstance().fbid = authData.uid
                            Users.sharedInstance().email = authData.providerData["email"] as! String
                            Users.sharedInstance().lat = ""
                            Users.sharedInstance().long = ""
                            //Req to 11002 (find in account) by email. IF success present VC. IF fail, Req to 111000, present VC.
                            
                            self.findAccount(Users.sharedInstance().email as! String)
                            //Start Location Auth
                            self.locManager.requestAlwaysAuthorization()
                            self.locManager.startUpdatingLocation()
                        }
                })
                })
            }
        })
    }
    
    func locRequest() {
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            currentLocation = locManager.location
        }
        else {
            print("no")
        }
    }
}