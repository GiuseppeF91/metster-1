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
    
    var loginButton = SubmitButton(frame: CGRectMake(10, screenHeight-200, UIScreen.mainScreen().bounds.width-20, (UIScreen.mainScreen().bounds.height)/12))
    
    var locManager = CLLocationManager()
    var currentLocation : CLLocation!
    var currentLat = ""
    var currentLong = ""
    var error : NSError?
    
    var metsLogo = UIImage(named: "logo")
    var stripeLogo = UILabel()
    
    let facebookLogin = FBSDKLoginManager()
    
    override func viewDidLoad() {
        print("====== ENTER Login View Controller =====")
        super.viewDidLoad()
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "homebackground")?.drawInRect(self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.backgroundColor = UIColor(patternImage: image).colorWithAlphaComponent(0.9)
        self.view.opaque = true

        locManager.delegate = self
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.frame = CGRectMake(40, screenHeight-70, UIScreen.mainScreen().bounds.width-80, 40)
        self.view.addSubview(loginView)
        loginView.readPermissions = ["email", "public_profile", "user_friends", "user_location", "user_photos"]
        loginView.delegate = self
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            self.activityIndicator.startAnimating()
            dispatch_async(dispatch_get_main_queue(), {
                
                self.returnUserFriends()
                self.returnUserData({ (success, errorString) in
                    guard success else {
                        dispatch_async(dispatch_get_main_queue(), {
                            print("Failed.")
                            self.alertMessage("Error", message: "failure")
                            self.activityIndicator.stopAnimating()
                        })
                        return
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        print("success")
                        Users.sharedInstance().lat = ""
                        Users.sharedInstance().long = ""
                        self.findAccount()
                        self.presentViewController(TabBarViewController(), animated: true, completion: nil)
                        self.activityIndicator.stopAnimating()
                    })
                })
            })
        } else {
            print("not logged in")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    // Facebook Delegate Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil) {
            print(ErrorType)
        }
        if result.isCancelled {
            // Handle cancellations
            print(ErrorType)
        } else {
            //Start Location Auth
            self.locManager.requestAlwaysAuthorization()
            self.locManager.startUpdatingLocation()
            print("user data returned")
            
            returnUserData({ (success, errorString) in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Failed.")
                        self.alertMessage("Error", message: "failure")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    Users.sharedInstance().lat = ""
                    Users.sharedInstance().long = ""
                    self.findAccount()
                })
            })
            
            returnUserFriends()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        facebookLogin.logOut()
        let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
        deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
            print("the delete permission is \(result)")
            
        })
        print("User Logged Out")
    }
    
    // get all user friends
    func returnUserFriends() {
    print("enter returnUserFriends ----->")
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/friends", parameters: ["fields": "name, email"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            //TO DO: THIS NEEDS TO BE IMPLEMENTED TO RETURN ONLY AUTHORIZED APP USERS. Also needs to return the EMAILS of each listed user.
            print (result)
            if error == nil {
                print("Friends are : \(result)")
                let data = result.valueForKey("data")
                //print(data?.valueForKey("email"))
                
                let friends = data?.valueForKey("name")
                Users.sharedInstance().user_friends = friends as? NSArray
            } else {
                print("Error Getting Friends \(error)")
                Users.sharedInstance().user_friends = []
            }
        })
        print("exit returnUserFriends ----->")
    }
    
    func returnUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        print("enter returnUserData ----->")
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, name, gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil) {
                // Process error
                print("Error: \(error)")
            } else {
                completionHandler(success: true, errorString: nil)
                print("fetched user: \(result)")
                Users.sharedInstance().name = result.valueForKey("name") as! NSString
                print("User Name is: \(Users.sharedInstance().name)")
                if result.valueForKey("email") == nil {
                    Users.sharedInstance().email = result.valueForKey("id")
                } else {
                    Users.sharedInstance().email = result.valueForKey("email") as! NSString
                }
                Users.sharedInstance().fbid = result.valueForKey("id") as! NSString
                Users.sharedInstance().gender = result.valueForKey("gender") as! NSString
                
            }
        })
        print("exit returnUserData ----->")
    }

    func createAccount() {
        print("enter createAccount ----->")
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
                self.findAccount()
                
                self.presentViewController(TabBarViewController(), animated: true, completion: nil)
            })
        }
        print("exit createAccount ----->")
    }

    func findAccount() {
        print("enter findAccount ----->")
        RequestInfo.sharedInstance().postReq("111002")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("didn't find account")
                    self.createAccount()
                })
                return
            }
            print("This user exists")
            self.presentViewController(TabBarViewController(), animated: true, completion: nil)
        }
        print("exit findAccount ----->")
    }
    
    func locRequest() {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
            currentLocation = locManager.location
            
        } else {
            print("no")
        }
    }
}