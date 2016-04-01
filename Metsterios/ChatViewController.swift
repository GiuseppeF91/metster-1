//
//  ChatViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    var navBar = UINavigationBar(frame: CGRectMake(0, 25, UIScreen.mainScreen().bounds.width, (UIScreen.mainScreen().bounds.height)/12))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.backgroundColor = UIColor.whiteColor()
        navBar.tintColor = UIColor.blackColor()
        navigationItem.title = "Chat"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
        
        findFood()
    }
    
    func findFood() {
        let newReq : dataRequest = dataRequest()
        newReq.oper = "999000"
        newReq.eventid = "10103884620845432--event--20"
        newReq.search = "sushi"
        newReq.post_req()
        
        print("ok")
        dispatch_async(dispatch_get_main_queue()){
            
            print("meow")
            let jsonStringAsArray = newReq.returnedInfo
            let data: NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
            var error : NSError!
            do {
                let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                let secondPart = anyObj["response"] as! String
                print(secondPart)
                let secondPartArray = secondPart.componentsSeparatedByString(":")
                
                print("shut")
                
            } catch {
                print(error)
            }
            
        }
        
    }
    
    func newEvent() {
        let newReq : dataRequest = dataRequest()
        newReq.oper = "121000"
        newReq.emailAddress = "navimn1991@gmail.com"
        newReq.event_name = "Burgers"
        newReq.event_date = "03/30/2016"
        newReq.event_time = "17:00"
        newReq.event_notes = "burgers burglars"
        newReq.event_members = ["John Fonds", "Bob JR"]
        newReq.post_req()
        print("meow")
        let jsonStringAsArray = newReq.returnedInfo
        let data: NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
        var error : NSError!
        
        do {
            let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            print(anyObj)
            print("shut")
            
        } catch {
            print(error)
        }
    }
    
}