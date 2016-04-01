//
//  RequestInfo.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/31/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation


var betterData = String()

class RequestInfo {
    
    //var dictionary = []
    var key = "22"
    var email = UserVariables.email

    var query = UserVariables.query
    var event_id = UserVariables.event_id
    var fb_id = UserVariables.fbid
    var name = UserVariables.name
    var latitude = UserVariables.lat

    var longitude = UserVariables.long
    var event_name = UserVariables.event_id
    var event_date = UserVariables.event_date
    
    var event_time = UserVariables.event_time
    var event_notes = UserVariables.event_notes
    var event_members = UserVariables.event_members
    
    var what = UserVariables.what
    var movie_pref = UserVariables.movie_pref
    var food_pref = UserVariables.food_pref
    
    var dictionary  = NSDictionary()
    
    var theData = NSData()
   
    func findFoodRequest(query: String, event_id: String) {
        let oper = "999000"
        //dictionary = ["query":query, "event_id":event_id]
    }
    
    func postReq(oper: String) {
        
        if oper == "111002" { //#find in account
            dictionary = ["email": email]
        }
        
        if oper == "999000" {
            dictionary = ["query":query, "event_id":event_id]
        }
        
        if oper == "111000" {  //#insert to account
    
            dictionary = ["dev_id": "12er34", "email": email, "fb_id": fb_id, "name": name, "invites":"none", "hosted":"none", "joined": "none", "latitude": latitude, "longitude": longitude, "food_pref": "Chinese", "moviepref": "Horror"]
            }
            
        if oper == "111003" { //update in account
            
            dictionary = ["email": email, "what": what, "movie_pref": movie_pref, "food_pref": food_pref]
            }
            
        if oper == "121000" { //insert to events
            dictionary = ["host_email": email, "event_name": event_name, "event_date": event_date, "event_time": event_time, "event_notes": event_notes, "event_members": event_members]
            }
            
        if oper == "998000" { //accept invite
            dictionary = ["email": email, "event_id": event_id]
            }
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        var error : NSError?
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        
        guard error == nil else {
            print(ErrorType)
            return
        }
    
        var myString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
            //print(myString)
        let myRequestString = NSString(format: "operation=%@&key=%@&payload=%@", oper, key, myString!)
        let myRequestData = NSData(bytes: myRequestString.UTF8String, length: myRequestString.length)
            request.HTTPBody = myRequestData
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            

            var content = String(data: data!, encoding: NSUTF8StringEncoding)
            print(content)
            var data: NSData = (content!.dataUsingEncoding(NSUTF8StringEncoding))!
                do {
                    
                    let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
        
                    let aData = (responseData["response"] as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    //print(newData)
                    var bData = String(data: aData!, encoding: NSUTF8StringEncoding)
                    var cData = bData!.stringByReplacingOccurrencesOfString("'", withString: "\"", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    var ccData = cData.stringByReplacingOccurrencesOfString("u", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    var cccData = ccData.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    var ccccData = cccData.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    var cccccData = ccccData.stringByReplacingOccurrencesOfString("ObjectId", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    print(cccccData)
                    print(cccccData.characters.count)
                    
                    let dData = (cccccData as! NSString).dataUsingEncoding(NSUTF8StringEncoding)
                    let eData = String(data: dData!, encoding: NSUTF8StringEncoding)
                    let fData : NSData = (eData?.dataUsingEncoding(NSUTF8StringEncoding))!

                    do {
                        let useME = try NSJSONSerialization.JSONObjectWithData(fData, options: .AllowFragments)
                        print("USE MEEEEE")
                        print(useME)
                    }
                    
                } catch {
                    print(error)
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
