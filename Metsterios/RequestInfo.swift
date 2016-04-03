//
//  RequestInfo.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/31/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

class RequestInfo {
   
    var key = "22"
    var email = Users.sharedInstance().email

    var query = Users.sharedInstance().query
    var event_id = Users.sharedInstance().event_id
    var fb_id = Users.sharedInstance().fbid
    var name = Users.sharedInstance().name
    var latitude = Users.sharedInstance().lat

    var longitude = Users.sharedInstance().long
    var event_name = Users.sharedInstance().event_id
    var event_date = Users.sharedInstance().event_date
    
    var event_time = Users.sharedInstance().event_time
    var event_notes = Users.sharedInstance().event_notes
    var invited_members = Users.sharedInstance().invited_members
    var event_members = Users.sharedInstance().event_members
    
    var what = Users.sharedInstance().what
    var movie_pref = Users.sharedInstance().movie_pref
    var food_pref = Users.sharedInstance().food_pref
    
    var dictionary  = NSDictionary()
    var error : NSError?
    
    func parseFoodRequest(responseData: NSDictionary ) {
        let response =  (responseData["response"]) as! NSDictionary
        let restaurantString = (response.allValues[0] as! String)
        let restaurantData : NSData = (restaurantString.dataUsingEncoding(NSUTF8StringEncoding))!
        do {
            let restaurantInfo = try NSJSONSerialization.JSONObjectWithData(restaurantData as NSData, options: .AllowFragments) as! NSDictionary
            
            print(restaurantInfo)
            print(restaurantInfo["name"])
        } catch {
            print(ErrorType)
        }
    }
    
    func parseAccountInfo(responseData: NSDictionary) {
        let aData = (responseData["response"] as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let bData = String(data: aData!, encoding: NSUTF8StringEncoding)
        let cData = bData!.stringByReplacingOccurrencesOfString("'", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let ccData = cData.stringByReplacingOccurrencesOfString("u", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let cccData = ccData.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let ccccData = cccData.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let cccccData = ccccData.stringByReplacingOccurrencesOfString("ObjectId", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let dData = (cccccData as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        let eData = String(data: dData!, encoding: NSUTF8StringEncoding)
        
        let fData : NSData = (eData?.dataUsingEncoding(NSUTF8StringEncoding))!
        
        do {
            let useME : NSDictionary = try NSJSONSerialization.JSONObjectWithData(fData, options: .AllowFragments) as! NSDictionary
            
            print("USE MEEEEE")
            print(useME)
            let userName = useME["name"]
            let email = useME["email"]
            let latitude = useME["latitde"]
            let hosted = useME["hosted"]
            let joined = useME["joined"]
            let invites  = useME["invites"]
            print(userName)
            print(email)
            
            Users.sharedInstance().hosted = hosted
            Users.sharedInstance().joined = joined
            Users.sharedInstance().pending = invites
            Users.sharedInstance().email = email
            
        } catch {
            print(ErrorType)
        }
    }
    
    func postReq(oper: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if oper == "111002" { //#find in account
            dictionary = ["email": email!]
        }
        
        if oper == "999000" { //Find Fooood
            dictionary = ["query":query! , "event_id":event_id!]
        }
        
        if oper == "111000" {  //#insert to account
    
            dictionary = ["dev_id": "12er34", "email": email!, "fb_id": fb_id!, "name": name!, "invites":"none", "hosted":"none", "joined": "none", "latitude": latitude!, "longitude": longitude!, "food_pref": "Chinese", "moviepref": "Horror"]
            }
            
        if oper == "111003" { //update in account
            dictionary = ["email": email!, "what": what!, "movie_pref": movie_pref!, "food_pref": food_pref!]
            }
            
        if oper == "121000" { //insert to events
            dictionary = ["host_email": email!, "event_name": event_name!, "event_date": event_date!, "event_time": event_time!, "event_notes": event_notes!, "event_members": invited_members!]
            }
            
        if oper == "998000" { //accept invite
            dictionary = ["email": email!, "event_id": event_id!]
            }
        
        if oper == "998001" { //senddd invite
            dictionary = ["from_email": email!, "event_id": event_id!, "to_email": invited_members!]
        }
        
        if oper == "121001" { //delete in events
            dictionary = ["email": email!, "event_id": event_id!]
        }
        
        if oper == "998002" { //reject invite
            dictionary = ["email": email!, "event_id": event_id!]
        }
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        guard error == nil else {
            print(ErrorType)
            return
        }
    
        let myString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
            //print(myString)
        let myRequestString = NSString(format: "operation=%@&key=%@&payload=%@", oper, key, myString!)
        let myRequestData = NSData(bytes: myRequestString.UTF8String, length: myRequestString.length)
            request.HTTPBody = myRequestData
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                print(ErrorType)
                return
            }
            let content = String(data: data!, encoding: NSUTF8StringEncoding)
            let data: NSData = (content!.dataUsingEncoding(NSUTF8StringEncoding))!
        
            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                print(responseData)
                    if oper == "111002" {
                       self.parseAccountInfo(responseData)
                    }
                    if oper == "999000" {
                        //self.parseFoodRequest(responseData)
                    }
                }catch {
                    print(ErrorType)
            }
        })
        task.resume()
    }
    
    class func sharedInstance() -> RequestInfo {
        struct Singleton {
            static var sharedInstance = RequestInfo()
        }
        return Singleton.sharedInstance
    }
}
