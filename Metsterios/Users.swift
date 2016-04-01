//
//  Users.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/31/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

class Users: NSObject {
    
    var name : String?
    var email : String?
    var fbid : String?
    var lat : String?
    var long : String?
    var food_pref : String?
    var movie_pref : String?
    var what : String?
    
    var eventName : String?
    var query : String?
    var event_id : String?
    var event_date : String?
    var event_time : String?
    var event_notes : String?
    var event_members = []

    class func sharedInstance() -> Users {
        struct Singleton {
            static var sharedInstance = Users()
        }
        return Singleton.sharedInstance
    }
}