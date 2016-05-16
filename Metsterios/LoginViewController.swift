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
import Haneke
import Quickblox

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
        self.view.backgroundColor = hexStringToUIColor("#fd5c63")
        self.view.opaque = true
        
        stripeLogo.frame = CGRectMake(0, screenHeight/3, screenWidth, screenHeight/6)
        stripeLogo.backgroundColor = UIColor.clearColor()
        stripeLogo.center = self.view.center
        view.addSubview(stripeLogo)
        
        let logoView = UIImageView(image: metsLogo)
        logoView.frame = CGRect(x: screenWidth, y: screenHeight, width: screenWidth, height: screenHeight)
        logoView.contentMode = UIViewContentMode.ScaleAspectFit
        logoView.center = self.view.center
        view.addSubview(logoView)
        
        locManager.delegate = self
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.frame = CGRectMake(40, screenHeight-70, UIScreen.mainScreen().bounds.width-80, 40)
        self.view.addSubview(loginView)
        loginView.readPermissions = ["email", "public_profile", "user_friends", "user_location", "user_photos", "user_about_me"]
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
                        self.activityIndicator.stopAnimating()
                    })
                })
            })
        } else {
            print("not logged in")
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
            //let token:FBSDKAccessToken = result.token
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
    let cache = Shared.dataCache
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
                
                let friendsid = data?.valueForKey("id")
                Users.sharedInstance().user_friends_id = friendsid as? NSArray
                
                for id in Users.sharedInstance().user_friends_id! {
                    let access = id as! String
                    let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
                    
                    //---- cache image management
                    cache.fetch(key: access).onFailure { data in
                        
                        print (access)
                        let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
                        ) { (responseData, responseUrl, error) -> Void in
                            if let data = responseData{
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    let image : UIImage = UIImage(data: data)!
                                    cache.set(value: image.asData(), key: access)
                                })
                            }
                        }
                        task.resume()
                        
                    }
                    
                    cache.fetch(key: access).onSuccess { data in
                        print ("data was found in cache for a friend")
                        // let image : UIImage = UIImage(data: data)!
                        // self.profImage!.image = image
                    }
                    //-----
                    
                }
                
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
                print(result.valueForKey("about_me")) // typo here
                
            }
        })
        print("exit returnUserData ----->")
    }

    func createAccount() {
        print("enter createAccount ----->")
        Users.sharedInstance().movie_pref = "abcdefghijkl"
        Users.sharedInstance().food_pref = "abcdefhijkl"
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

            })
        }
        print("exit createAccount ----->")
    }

    func findAccount() {
        print("enter findAccount ----->")
        Users.sharedInstance().mfbid = "123"
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
            print (Users.sharedInstance().fbid as! String)
            
            QBRequest.logInWithUserLogin(Users.sharedInstance().fbid as! String, password: Users.sharedInstance().fbid as! String, successBlock: { (response:QBResponse, user : QBUUser?) in
                
                
                }, errorBlock: { (response: QBResponse) in
                    let user = QBUUser()
                    print ("here")
                    user.password = (Users.sharedInstance().fbid as! String)
                    user.login = (Users.sharedInstance().fbid as! String)
                    print (user.login)
                    QBRequest.signUp(user, successBlock: { (response: QBResponse, user :QBUUser?) in
                        
                        
                        }, errorBlock: { (request: QBResponse) in
                            
                            
                    })
                    
            })
            
            self.registerForRemoteNotification()

            self.presentViewController(TabBarViewController(), animated: true, completion: nil)
        }
        print("exit findAccount ----->")
    }
    
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func locRequest() {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways) {
            currentLocation = locManager.location
            
        } else {
            print("no")
        }
    }
}