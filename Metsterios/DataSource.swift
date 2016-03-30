//
//  DataSource.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/29/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

class DataService {
    
    func findFood() {
        
        let oper = "999000"
        let key = "223"
        let query = "sushi"
        let event_id = "10103884620845515--event--0"
        var error : NSError?
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var myRequestString = NSString(format: "operation=%@&key=%@&payload=%@", oper, key, query, event_id)
        var myRequestData = NSData(bytes: myRequestString.UTF8String, length: myRequestString.length)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"content-type")
        request.HTTPBody = myRequestData
        
        
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            var content = String(data: data!, encoding: NSUTF8StringEncoding)!
            
            var jData = content.dataUsingEncoding(NSUTF8StringEncoding)
            
            do {
                
                let JSON = try NSJSONSerialization.JSONObjectWithData(jData!, options: .MutableContainers)
                
                
                print("responseData: %@", JSON)
                
            } catch {
                print("error")
            }
              print("responseData: %@", content)
            
        })
        task.resume()
     
    }
      
        
}