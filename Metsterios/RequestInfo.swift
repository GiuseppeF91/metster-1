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
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
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
            print(useME)
            let hosted = useME["hosted"]
            let joined = useME["joined"]
            let invites  = useME["invites"]
            let food_pref = useME["food_pref"]
            let movie_pref = useME["movie_pref"]
            let gid = useME["gid"]
            let me = useME["ame"]
            //let email = useME["email"]
            //let name = useME["name"]
            //Users.sharedInstance().email = email
            //Users.sharedInstance().name = name
            Users.sharedInstance().gid = gid
            Users.sharedInstance().aboutme = me
            Users.sharedInstance().hosted = hosted as? NSArray
            Users.sharedInstance().joined = joined as? NSArray
            Users.sharedInstance().pending = invites as? NSArray
            Users.sharedInstance().food_pref = food_pref
            Users.sharedInstance().movie_pref = movie_pref
            
        } catch {
            print(ErrorType)
        }
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    func parseEventInfo(responseData: NSDictionary) {
        print ("Enter parse event")
        print(responseData["response"])
        let useME = responseData["response"]! as! Dictionary<String, String> as Dictionary        // testibg

            let evnt = userevents(eid: useME["mid"]!,
                       ename: useME["event_name"]!,
                       ehost: useME["host_email"]!,
                       edesp: useME["event_notes"]!,
                       edate: useME["event_date"]!,
                       etime: useME["event_time"]!,
                       ehostname: useME["host_name"]!,
                       emembers: useME["event_members"]!)
            
            Users.sharedInstance().event_dic.updateValue(evnt, forKey: useME["mid"]!)
         print ("Exit parse event")
    }
    
    func postReq(oper: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        print("req started")
        
        if oper == "997000" { //insert venue info to firebase
            //TODO: THIS IS NOT WORKING
             print("insert req for firebase")
            dictionary = ["event_id": Users.sharedInstance().event_id!, "place_id": Users.sharedInstance().place_id!, "email": Users.sharedInstance().email!,"place_info": Users.sharedInstance().place_info!]
        }
        
        if oper == "121002" {
            print("find req for event")
            dictionary = ["event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "111003" { // update account pref
            print("update req for account")
            if (Users.sharedInstance().movie_pref == nil ){
                Users.sharedInstance().movie_pref = "abcdefghijkl"
            }
            if(Users.sharedInstance().food_pref == nil) {
                Users.sharedInstance().food_pref = "abcdefghijkl"
            }
            dictionary = ["email": Users.sharedInstance().email!, "latitude": Users.sharedInstance().lat!,"longitude": Users.sharedInstance().long!, "movie_pref": Users.sharedInstance().movie_pref!,"ame": Users.sharedInstance().aboutme!, "food_pref": Users.sharedInstance().food_pref!]
        }
        
        if oper == "111002" { // find in account
            print("find req in account")
            dictionary = ["email": Users.sharedInstance().email!,
                          "fid": Users.sharedInstance().mfbid!]
        }
        
        if oper == "998100" {
            print("public search")
            dictionary = ["email": Users.sharedInstance().email!,
                          "query": Users.sharedInstance().query!]
        }
        
        if oper == "999000" { // find fooood
            print("api req for food")
            print (Users.sharedInstance().search_mode as! String)
            switch(Users.sharedInstance().search_mode as! String) {
            case "private"  :
                dictionary = ["query": Users.sharedInstance().query! ,
                              "search_mode": Users.sharedInstance().search_mode! ,
                              "email": Users.sharedInstance().email!]
                break;
            case "public"  :
                dictionary = ["query": Users.sharedInstance().query! ,
                              "search_mode": Users.sharedInstance().search_mode! ,
                              "email": Users.sharedInstance().email!]
                break;
            case "group"  :
                dictionary = ["query": Users.sharedInstance().query! ,
                              "search_mode": Users.sharedInstance().search_mode! ,
                              "event_id": Users.sharedInstance().event_id!]
                break;
                
            default : /* Optional */
                dictionary = ["query": Users.sharedInstance().query! ,
                              "search_mode": "private" ,
                              "event_id": Users.sharedInstance().event_id!]
            }
            
        }
        
        if oper == "997666" { // tryout insert
            dictionary = ["email": Users.sharedInstance().email! ,
                          "place_id": Users.sharedInstance().tryout_place_id! ,
                          "message": Users.sharedInstance().tryout_message!]
        }
        
        if oper == "997667" {
            dictionary = ["email": Users.sharedInstance().email! ,
                          "place_id": Users.sharedInstance().tryout_place_id!]
        }
        
        if oper == "997670" {
            dictionary = ["email": Users.sharedInstance().email! ,
                          "event_id": Users.sharedInstance().vote_event_id!,
                          "place_id": Users.sharedInstance().vote_place_id!]
        }
        
        if oper == "111000" { // insert to account
            print("insert req into account")
            dictionary = ["dev_id": "12er34", "email": Users.sharedInstance().email!, "fb_id": Users.sharedInstance().fbid!, "name": Users.sharedInstance().name!, "invites": NSMutableArray(), "hosted": NSMutableArray(), "joined": NSMutableArray(), "latitude": Users.sharedInstance().lat!,"gender": Users.sharedInstance().gender!, "longitude": Users.sharedInstance().long!, "food_pref": "abcdefghijlm", "movie_pref": "abcdefghijlm"]
            }
            
        if oper == "121000" { // insert to events
            print("insert req into events")
            dictionary = ["host_email": Users.sharedInstance().email!, "event_name": Users.sharedInstance().eventName!, "event_date": Users.sharedInstance().event_date!, "event_time": Users.sharedInstance().event_time!, "event_notes": Users.sharedInstance().event_notes!, "event_members": Users.sharedInstance().invited_members!]
            }
            
        if oper == "998000" { // accept invite
            print("api req for accept invite")
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
            }
        
        if oper == "998001" { // send invite
            print("api req for send invite")
            dictionary = ["from_email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!, "to_email": Users.sharedInstance().invited_members!]
        }
        
        if oper == "121001" { // delete in events
             print("del req in events")
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
        }
        
        if oper == "998002" { // reject invite
            print("api req to reject invite")
            dictionary = ["email": Users.sharedInstance().email!, "event_id": Users.sharedInstance().event_id!]
        }
        
        
        //sanity wait of few sec before req to server
        delay(0.4) {
            // do stuff
            print("wait..")
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
                    print ("999000 req start")
                    let responseData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                    
                    if responseData.valueForKey("status") as! String == "success" {
                        
                        // clean data of previous search
                        Users.sharedInstance().place_ids?.removeAllObjects()
                        Users.sharedInstance().places?.removeAllObjects()
                        
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
                    print("------------ Server resp  -----")
                    print(oper)
                    print("-----------")
                    print(responseData)
                    print("-------------------------------")
                    if oper == "111000" {
                        if responseData.valueForKey("status") as! String == "success" {
                            completionHandler(success: true, errorString: nil)
                        } else {
                            completionHandler(success: false, errorString: "couldn't create account")
                        }
                    } else {
                        let status = responseData.valueForKey("status") as! String
                        let responseStat = responseData.valueForKey("response")
                        
                        if status == "fail" {
                            completionHandler(success: false, errorString: "that info does not exist")
                        }
                        
                        /*
                        if responseStat == "update failed" {
                            completionHandler(success: false, errorString: "Unable to update")
                        }
                        */
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
                            if oper == "998100" {
                                Users.sharedInstance().tryout_people = responseData.valueForKey("response")
                            }
                            
                            completionHandler(success: true, errorString: "info found")
                        }
                    }
                    
                }catch {
                    print("there was an error")
                    // got to error screen
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
