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
        
     
    }
   
    func findFood() {
        
        let oper = "999000"
        let key = "223"
        let query = "sushi"
        let event_id = "10103884620845432--event--1"
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        var error: NSError?
        request.HTTPMethod = "POST"
        
        //var params = [oper:"999000", key:"223", query:"sushi", event_id:"10103884620845515--event--0"] as Dictionary<String, String>
        
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var myRequestString = NSString(format: "operation=%@&key=%@&query=%@event_id=%@", oper, key, query, event_id).dataUsingEncoding(NSUTF8StringEncoding)
        var myRequestData = NSData(data: myRequestString!)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        
        var err : NSError?
        
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            var returnData = NSURLConnection()
            var content = (NSString(data: data!, encoding: NSUTF8StringEncoding))
            //let jData = NSData(data: content, encoding: NSUTF8StringEncoding)
            let JSON = NSDictionary()
            
        }
        task.resume()
    }
    
    func makeRequest(){
        
        let oper = "999000"
        let key = "223"
        let query = "sushi"
        let event_id = "10103884620845515--event--0"
        
        
        let urlString = "http://104.236.177.93:8888"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
       //var postData:NSData = parameters.dataUsingEncoding(NSASCIIStringEncoding)!
       // var postLength:NSString = String(postData.length )
        
        
        let postData = NSString(format: "{\"yes\": {\"oper\": \"%@\", \"key\":\"%@\", \"query\": \"%@\", \"event_id\":\"%@\"}}", oper, key, query, event_id).dataUsingEncoding(NSUTF8StringEncoding)
        var theLength : NSString = String(postData!.length)
    
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var error:NSError?
        
       
        print("MAKE")
        request.HTTPBody = postData
        request.setValue(theLength as String, forHTTPHeaderField: "Content-Length")
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse, let fields = httpResponse.allHeaderFields as? [String : String] {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: response!.URL!)
                NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response!.URL!, mainDocumentURL: nil)
                for cookie in cookies {
                    var cookieProperties = [String: AnyObject]()
                    cookieProperties[NSHTTPCookieName] = cookie.name
                    cookieProperties[NSHTTPCookieValue] = cookie.value
                    cookieProperties[NSHTTPCookieDomain] = cookie.domain
                    cookieProperties[NSHTTPCookiePath] = cookie.path
                    cookieProperties[NSHTTPCookieVersion] = NSNumber(integer: cookie.version)
                    cookieProperties[NSHTTPCookieExpires] = NSDate().dateByAddingTimeInterval(31536000)
                    
                    let newCookie = NSHTTPCookie(properties: cookieProperties)
                    NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookie(newCookie!)
                    
                    print("name: \(cookie.name) value: \(cookie.value)")
                }
            }
            })
            task.resume()

    }
}




















