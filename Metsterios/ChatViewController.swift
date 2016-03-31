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
        
        let newReq : dataRequest = dataRequest()
        newReq.oper = "111002"
        newReq.emailAddress = "navimn1991@gmail.com"
        
        newReq.post_req()
        print("meow")
        print(newReq.returnedInfo)
        
        let jsonStringAsArray = newReq.returnedInfo
        
        let data: NSData = jsonStringAsArray.dataUsingEncoding(NSUTF8StringEncoding)!
        var error: NSError!
        
        do {
            let anyObj = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            print("DICK SANDWICH")
            
            let secondPart = anyObj["response"] as! String
            
            let secondPartArray = secondPart.componentsSeparatedByString(":")
            print(secondPartArray)
            print("shut")
            print(secondPartArray[6])
            
            
        } catch {
            print(error)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
}