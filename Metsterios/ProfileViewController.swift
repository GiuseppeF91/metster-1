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

class ProfileViewController: BaseVC {
    
    var logoutButton = ProfileButton(frame: CGRectMake(0, (screenHeight)-(screenHeight/15)-50, screenWidth, screenHeight/14.5))
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
        
        var access = Users.sharedInstance().fbid as! String
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
        
        profImage = UIImageView()
        profImage?.frame = CGRectMake(screenWidth/3, screenHeight/7, screenWidth/3, screenWidth/3)
        profImage!.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(profImage!)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
        ) { (responseData, responseUrl, error) -> Void in
            if let data = responseData{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profImage!.image = UIImage(data: data)
                })
            }
        }
        task.resume()
        
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = Users.sharedInstance().name as? String
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 30)
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.nameLabel)
    }
    
    func logoutClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}