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
    var dictionary  = NSDictionary()
    var error : NSError?
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    func parseFoodInfo(responseStat: NSDictionary) {
        
        let keysone = Array(responseStat.allKeys).first
        let keystwo = Array(responseStat.allKeys).dropFirst().first
        let keysthree = Array(responseStat.allKeys).dropFirst().first
        let allkeys : NSMutableArray = [keysone!, keystwo!, keysthree!]
        Users.sharedInstance().places = allkeys
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
            
            print("Parsed data in req info")
            // print(useME)
            let hosted = useME["hosted"]
            let joined = useME["joined"]
            let invites  = useME["invites"]
            let food_pref = useME["food_pref"]
            let movie_pref = useME["movie_pref"]
            //let email = useME["email"]
            //let name = useME["name"]
            //Users.sharedInstance().email = email
            //Users.sharedInstance().name = name
            Users.sharedInstance().hosted = hosted as? NSArray
            Users.sharedInstance().joined = joined as? NSArray
            Users.sharedInstance().pending = invites as? NSArray
            Users.sharedInstance().food_pref = food_pref
            Users.sharedInstance().movie_pref = movie_pref
            
        } catch {
            print(ErrorType)
        }
    }
    
    func parseEventInfo(responseData: NSDictionary) {
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
            print ("dat here")
            print (useME)
            //userevents.init(key: String(useME["mid"]), dictionary: useME as! Dictionary<String, AnyObject>)
            //userevents.events.update
            let evnt = userevents(eid: useME["mid"] as! String,
                       ename: useME["event_name"] as! String,
                       ehost: useME["host_email"] as! String,
                       edesp: useME["event_notes"] as! String,
                       edate: useME["event_date"] as! String,
                       etime: useME["event_time"] as! String,
                       ehostname: useME["host_name"] as! String)
            
            Users.sharedInstance().event_dic.updateValue(evnt, forKey: useME["mid"] as! String)
            Users.sharedInstance().host_email = useME["host_email"] as! String
            
        } catch {
            print(ErrorType)
        }
    }
    
    func postReq(oper: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        print("req started")
        print(oper)
        
        if oper == "997000" { //insert venue info to firebase
            //TODO: THIS IS NOT WORKING
            dictionary = ["event_id": Users.sharedInstance().event_id!, "place_id": Users.sharedInstance().place_id!, "place_info": Users.sharedInstance().place_info!]
        }
        
        if oper == "121002" {
            dictionary = ["event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "111003" { // update account pref
            if (Users.sharedInstance().movie_pref == nil ){
                Users.sharedInstance().movie_pref = 0
            }
            if(Users.sharedInstance().food_pref == nil) {
                Users.sharedInstance().food_pref = 0
            }
            dictionary = ["email": Users.sharedInstance().email!, "latitude": Users.sharedInstance().lat!,"longitude": Users.sharedInstance().long!, "movie_pref": Users.sharedInstance().movie_pref!, "food_pref": Users.sharedInstance().food_pref!]
        }
        
        if oper == "111002" { // find in account
            dictionary = ["email": Users.sharedInstance().email!]
        }
        
        if oper == "999000" { // find fooood
            dictionary = ["query": Users.sharedInstance().query! , "event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "111000" { // insert to account
            dictionary = ["dev_id": "12er34", "email": Users.sharedInstance().email!, "fb_id": Users.sharedInstance().fbid!, "name": Users.sharedInstance().name!, "invites": NSMutableArray(), "hosted": NSMutableArray(), "joined": NSMutableArray(), "latitude": Users.sharedInstance().lat!, "longitude": Users.sharedInstance().long!, "food_pref": "abcdefghijl", "movie_pref": "abcdefghijl"]
            }
            
        if oper == "121000" { // insert to events
            dictionary = ["host_email": Users.sharedInstance().email!, "event_name": Users.sharedInstance().eventName!, "event_date": Users.sharedInstance().event_date!, "event_time": Users.sharedInstance().event_time!, "event_notes": Users.sharedInstance().event_notes!, "event_members": Users.sharedInstance().invited_members!]
            }
            
        if oper == "998000" { // accept invite
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
            }
        
        if oper == "998001" { // senddd invite
            dictionary = ["from_email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!, "to_email": Users.sharedInstance().invited_members!]
        }
        
        if oper == "121001" { // delete in events
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "998002" { // reject invite
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
        }
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.init(rawValue: 0))
        guard error == nil else {
            print("can't get data into the right form")
            return
        }
    
        let myString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
            //print(myString)
        let myRequestString = NSString(format: "operation=%@&key=%@&payload=%@", oper, key, myString!)
        let myRequestData = NSData(bytes: myRequestString.UTF8String, length: myRequestString.length)
            request.HTTPBody = myRequestData
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            guard error == nil else {
                print("unable to reach server")
                return
            }
            let content = String(data: data!, encoding: NSUTF8StringEncoding)
            let data: NSData = (content!.dataUsingEncoding(NSUTF8StringEncoding))!
            
            if oper == "999000" {
                do {
                    let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    
                    if responseData.valueForKey("status") as! String == "success" {
                        
                        let allValues : NSMutableArray? = []
                        let allKeys : NSMutableArray? = []
                        let responseStat = responseData.valueForKey("response") as! NSDictionary
                        
                        let values = Array(responseStat.allValues)
                        for value in values {
                            allValues?.insertObject(value, atIndex: 0)
                        }
                        
                        let keys = Array(responseStat.allKeys)
                        for key in keys {
                            allKeys?.insertObject(key, atIndex: 0)
                        }
                    
                        Users.sharedInstance().place_ids = allKeys
                        Users.sharedInstance().places = allValues
                        
                        completionHandler(success: true, errorString: nil)
                    }
                    if responseData.valueForKey("status") as! String != "success" {
                        completionHandler(success: false, errorString: "unable to connect")
                    }
                }catch {
                    print(ErrorType)
                }
            } else {
                do {
                    let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    //print(responseData)
                    print("response got here")
                    if oper == "111000" {
                        if responseData.valueForKey("status") as! String == "success" {
                            completionHandler(success: true, errorString: nil)
                        } else {
                            completionHandler(success: false, errorString: "couldn't create account")
                        }
                    } else {
                        let status = responseData.valueForKey("status") as! String
                        let responseStat = responseData.valueForKey("response") as! String
                        
                        if status == "fail" {
                            completionHandler(success: false, errorString: "that info does not exist")
                        }
                        
                        if responseStat == "update failed" {
                            completionHandler(success: false, errorString: "Unable to update")
                        }
                        
                        if status == "success" {
                            if oper == "121000" {
                                Users.sharedInstance().event_id = responseData.valueForKey("response")
                                //print(Users.sharedInstance().event_id)
                            }
                            if oper == "111002" {
                                self.parseAccountInfo(responseData)
                            }
                            if oper == "121002" {
                                self.parseEventInfo(responseData)
                            }
                            
                            completionHandler(success: true, errorString: "info found")
                        }
                    }
                    
                }catch {
                    print("there was an error")
                }
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
