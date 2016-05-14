//
//  Place.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/10/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation
import Firebase

class events {
    private var _eventid: String!
    private var _eventname: String!
    private var _eventhost: String!
    private var _eventdesp: String!
    private var _eventdate: String!
    private var _eventtime: String!
    
    var eventid: String {
        return _eventid
    }
    
    var eventname: String {
        return _eventname
    }
    
    var eventhost: String {
        return _eventhost
    }
    
    var eventdesp: String {
        return _eventdesp
    }
    
    var eventdate: String {
        return _eventdate
    }
    
    var eventtime: String {
        return _eventtime
    }
    
    // Initialize
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._eventid = key
        
        // Within the placeID, or Key, the following properties are children
        if let eventname = dictionary["eventname"] as? String {
            self._eventname = eventname
        }
        
        if let eventid = dictionary["eventid"] as? String {
            self._eventid = eventid
        }
        
        if let eventdate = dictionary["eventdate"] as? String {
            self._eventdate = eventdate
        }
        
        if let eventname = dictionary["eventname"] as? String {
            self._eventname = eventname
        }
        
        if let eventtime = dictionary["eventtime"] as? String {
            self._eventtime = eventtime
        }
        
        if let eventdesp = dictionary["evendesp"] as? String {
            self._eventdesp = eventdesp
        }
        
    }
}
