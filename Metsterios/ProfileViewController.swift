//
//  ProfileViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Haneke

class ProfileViewController: BaseVC {
    
    var logoutButton = LogoutButton(frame: CGRectMake(0, (screenHeight)-(screenHeight/15)-60, screenWidth, screenHeight/14.5))
    var aboutButton = ProfileButton(frame: CGRectMake(0, screenHeight/2 + screenHeight/16 + 10, screenWidth, screenHeight/14.5))
    
    var notifyButton = ProfileButton(frame: CGRectMake(0, screenHeight/2 + (screenHeight/16)*2 + 20, screenWidth, screenHeight/14.5))
    var notifySwitch = UISwitch(frame:CGRectMake(screenWidth-80, screenHeight/2 + (screenHeight/16)*2 + 25, 0, 0))
    
    var publishButton = ProfileButton(frame: CGRectMake(0, screenHeight/2 + (screenHeight/15)*3 + 30, screenWidth, screenHeight/14.5))
    var publishSwitch = UISwitch(frame:CGRectMake(screenWidth-80, screenHeight/2 + (screenHeight/15)*3 + 35, 0, 0))
    
    var addressButton = ProfileButton(frame: CGRectMake(0, screenHeight/2, screenWidth, screenHeight/14.5))
    
    var nameLabel = UILabel(frame: CGRectMake(20, screenHeight/2.5, screenWidth-40, 40))
    var profImage : UIImageView?
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aboutButton.setTitle("About", forState: .Normal)
        self.view.addSubview(aboutButton)
        
        notifyButton.setTitle("Notifications", forState: .Normal)
        self.view.addSubview(notifyButton)
        
        notifySwitch.on = true
        notifySwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(notifySwitch)
        
        publishButton.setTitle("Publish Activity", forState: .Normal)
        self.view.addSubview(publishButton)
        
        publishSwitch.on = true
        publishSwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(publishSwitch)
        publishButton.hidden = true
        publishSwitch.hidden = true 
        
        addressButton.setTitle("Address", forState: .Normal)
        self.view.addSubview(addressButton)
        
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(ProfileViewController.logoutClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutButton)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let cache = Shared.dataCache
        let access = Users.sharedInstance().fbid as! String
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
        
        //
        profImage = UIImageView(frame: CGRectMake(screenWidth/4, screenHeight/9, self.view.bounds.width * 0.50 , self.view.bounds.height * 0.29))
        profImage?.layer.borderWidth = 0.3
        profImage?.layer.masksToBounds = false
        profImage?.layer.borderColor = UIColor.blackColor().CGColor
        profImage?.layer.cornerRadius = profImage!.frame.width/2
        profImage?.clipsToBounds = true
        self.view.addSubview(profImage!)
        //
        
        //---- cache image management
        cache.fetch(key: "profile_image.jpg").onFailure { data in
            
            print ("data was not found in cache")
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.profImage!.image = UIImage(data: data)
                        let image : UIImage = UIImage(data: data)!
                        cache.set(value: image.asData(), key: "profile_image.jpg")
                    })
                }
            }
            task.resume()
            
        }
        
        cache.fetch(key: "profile_image.jpg").onSuccess { data in
            print ("data was found in cache")
            let image : UIImage = UIImage(data: data)!
            self.profImage!.image = image
        }
        //-----
        
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = Users.sharedInstance().name as? String
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.nameLabel)
    }
    
    func logoutClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}