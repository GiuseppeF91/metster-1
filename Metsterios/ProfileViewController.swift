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
    
    var logoutButton = UIButton(frame: CGRectMake(0, (UIScreen.mainScreen().bounds.height)-(UIScreen.mainScreen().bounds.height/15)-50, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/15))
    
    var aboutButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2 + UIScreen.mainScreen().bounds.height/16 + 10, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/15))
    var notifyButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2 + (UIScreen.mainScreen().bounds.height/16)*2 + 20, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/15))
    
    var publishButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2 + (UIScreen.mainScreen().bounds.height/15)*3 + 30, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/15))
    var addressButton = UIButton(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height/2, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height/15))
    
    var nameLabel = UILabel(frame: CGRectMake(20, UIScreen.mainScreen().bounds.height/2.5, UIScreen.mainScreen().bounds.width-40, 40))
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = Users.sharedInstance().name as? String
        print(Users.sharedInstance().name)
        
        nameLabel.font = UIFont(name: "HelveticaNeue-", size: 30)
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.nameLabel)
        
        aboutButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        aboutButton.setTitle("About", forState: .Normal)
        aboutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.view.addSubview(aboutButton)
        
        notifyButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        notifyButton.setTitle("Notifications", forState: .Normal)
        notifyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.view.addSubview(notifyButton)
        
        publishButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        publishButton.setTitle("Publish Activity", forState: .Normal)
        publishButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.view.addSubview(publishButton)
        
        addressButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        addressButton.setTitle("Address", forState: .Normal)
        addressButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        self.view.addSubview(addressButton)
        
        logoutButton.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(ProfileViewController.logoutClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutButton)
    }
    
    func logoutClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}