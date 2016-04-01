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

class LoginViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var loginButton = SubmitButton(frame: CGRectMake(10, 100, UIScreen.mainScreen().bounds.width-20, (UIScreen.mainScreen().bounds.height)/12))
    
    var locManager = CLLocationManager()
    var currentLocation : CLLocation!
    var currentLat = ""
    var currentLong = ""
    
    let ref = Firebase(url: "https://mets.firebaseio.com")
    let facebookLogin = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() == nil){
            print ("not logged in")
            
        } else {
            print ("logged in")
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            self.ref.authWithOAuthProvider("facebook", token: accessToken,
                                           withCompletionBlock: { error, authData in
                                            if error != nil {
                                                print("Login failed. \(error)")
                                            } else {
                                                
                                                print("Logged in firebase ! \(authData)")
                                                
                                                // Authentication just completed successfully :)
                                                // The logged in user's unique identifier
                                                print(authData.uid)
                                                UserVariables.name = authData.providerData["displayName"] as! String
                                                UserVariables.fbid = authData.uid
                                                UserVariables.email = authData.providerData["email"] as! String
                                                UserVariables.lat = ""
                                                UserVariables.long = ""
                                                print(UserVariables.name, "is logged in")
                               
                                            }
                })
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                
            })
        }
        
        loginButton.center = self.view.center
        loginButton.setTitle("Login with Facebook", forState: .Normal)
        loginButton.addTarget(self, action: #selector(LoginViewController.loginNow), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
    }
    
    func createAccount(name: String, email: String, fbid: String, lat: String, long: String) {
        let newAccountReq : dataRequest = dataRequest()
        newAccountReq.oper = "111000"
        newAccountReq.emailAddress = email
        newAccountReq.fbid = fbid
        newAccountReq.name = name
        newAccountReq.latitude = lat
        newAccountReq.longitude = long
        
        let jsonStringAsArray = newAccountReq.returnedInfo
        let data : NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError!
        
        do {
            let newAccountInfo = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            let statCreation = newAccountInfo["status"] as! String
            if statCreation == "fail" {
                print("Failed at account creation.")
                //alertMessage("Error", message: "Your Account Info Was Not Saved.")
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            } else {
                print("account is hereeeee")
                print(newAccountInfo["response"])
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            }
            
        } catch {
            print(error)
        }
    }
    
    func findAccount(email: String) {
        RequestInfo.sharedInstance().postReq("111002")
        print("meow")
        let loginReq : dataRequest = dataRequest()
        print(UserVariables.name)
        print("finding out if account already exists meeeeowe")
        let jsonStringAsArray = loginReq.returnedInfo
        let data: NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError!
        
        do {
            let exisitingAcctInfo = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            let statLogin = exisitingAcctInfo["status"] as! String
            if statLogin == "success"
            {
                print("This user exists:")
                print(exisitingAcctInfo["response"])
                
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            } else {
               createAccount(UserVariables.name, email: UserVariables.email, fbid: UserVariables.fbid, lat: UserVariables.lat, long: UserVariables.long)
            }

        } catch {
            print(error)
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
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            print("Logged in firebase ! \(authData)")
                            
                            // Authentication just completed successfully :)
                            // The logged in user's unique identifier
                
                            UserVariables.name = authData.providerData["displayName"] as! String
                            UserVariables.fbid = authData.uid
                            UserVariables.email = authData.providerData["email"] as! String
                            UserVariables.lat = ""
                            UserVariables.long = ""
                            //Req to 11002 (find in account) by email. IF success present VC. IF fail, Req to 111000, present VC.
                        }
                })
            }
 
        })
        findAccount(UserVariables.email)
        //Start Location Auth
        locManager.requestAlwaysAuthorization()
        locManager.startUpdatingLocation()
    }
    
    func locRequest() {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            currentLocation = locManager.location
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