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
            let hosted = useME["hosted"]
            let joined = useME["joined"]
            let invites  = useME["invites"]
            let food_pref = useME["food_pref"]
            let movie_pref = useME["movie_pref"]
            //let email = useME["email"]
            //let name = useME["name"]
            //Users.sharedInstance().email = email
            //Users.sharedInstance().name = name
            Users.sharedInstance().hosted = hosted as! NSArray
            Users.sharedInstance().joined = joined as! NSArray
            Users.sharedInstance().pending = invites as! NSArray
            Users.sharedInstance().food_pref = food_pref
            Users.sharedInstance().movie_pref = movie_pref
            
        } catch {
            print(ErrorType)
        }
    }
    
    func postReq(oper: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        print("req started")
        print(Users.sharedInstance().email)
        
        if oper == "997000" { //insert venue info to firebase
            //TODO: THIS IS NOT WORKING
            dictionary = ["event_id": Users.sharedInstance().event_id!, "place_id": Users.sharedInstance().place_id!, "place_info": Users.sharedInstance().place_info!]
        }
        
        if oper == "111003" { // edit account pref
            print(Users.sharedInstance().food_pref)
            print(Users.sharedInstance().movie_pref)
            print(Users.sharedInstance().what)
            
            dictionary = ["email": Users.sharedInstance().email!, "what": Users.sharedInstance().what!, "movie_pref": Users.sharedInstance().movie_pref!, "food_pref": Users.sharedInstance().food_pref!]
        }
        
        if oper == "111002" { // find in account
            dictionary = ["email": Users.sharedInstance().email!]
        }
        
        if oper == "999000" { // find fooood
            print("foooooood")
            print(Users.sharedInstance().query)
            print(Users.sharedInstance().event_id)
            dictionary = ["query": Users.sharedInstance().query! , "event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "111000" { // insert to account
            dictionary = ["dev_id": "12er34", "email": Users.sharedInstance().email!, "fb_id": Users.sharedInstance().fbid!, "name": Users.sharedInstance().name!, "invites": NSMutableArray(), "hosted": NSMutableArray(), "joined": NSMutableArray(), "latitude": Users.sharedInstance().lat!, "longitude": Users.sharedInstance().long!, "food_pref": "Chinese", "movie_pref": "Horror"]
            }
            
        if oper == "121000" { // insert to events
            dictionary = ["host_email": Users.sharedInstance().email!, "event_name": Users.sharedInstance().eventName!, "event_date": Users.sharedInstance().event_date!, "event_time": Users.sharedInstance().event_time!, "event_notes": Users.sharedInstance().event_notes!, "event_members": Users.sharedInstance().invited_members!]
            }
            
        if oper == "998000" { // accept invite
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
            }
        
        if oper == "998001" { // senddd invite
            print("SEND INVITESSSS")
            print(Users.sharedInstance().event_id)
            print(Users.sharedInstance().invited_members)
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
            
            print(content)
        
            do {
                let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                print(responseData)
                if oper == "999000" {
                    if responseData.valueForKey("status") as! String == "success" {
                        let responseStat = responseData.valueForKey("response")
                        
                        let firstKey = Array(responseStat!.allKeys).first
                        let place_id = firstKey as! String
                        Users.sharedInstance().place_id = place_id
                        Users.sharedInstance().place_info = responseStat![place_id]
                        
                        print("HERE IS WHERE YOU ARE GOING")
                        print(Users.sharedInstance().place_id)
                        print(Users.sharedInstance().place_info)
                        completionHandler(success: true, errorString: nil)
                    } else {
                        completionHandler(success: false, errorString: "unable to connect")
                    }
                }
                
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
                            print(Users.sharedInstance().event_id)
                        }
                        if oper == "111002" {
                            self.parseAccountInfo(responseData)
                        }
                        completionHandler(success: true, errorString: "info found")
                    }
                }
                
            }catch {
                print("there was an error")
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
