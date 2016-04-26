//
//  Place.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/10/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation
import Firebase

class Place {
    private var _placeRef: Firebase!
    
    private var _placeKey: String!
    private var _address: String!
    private var _category: String!
    //private var _coordinate: String!
    private var _image_url: String!
    private var _latitude: String!
    private var _longitude: String!
    private var _name: String!
    private var _drivedistance: String!
    //private var _phone: String!
    //private var _rank: String!
    //private var _ratings: String!
    //private var _review_count: String!
    //private var _snippet: String!
    //private var _url: String!
    private var _eventid: String!
    private var _eventdate: String!
    private var _eventname: String!
    private var _eventtime: String!
    
    var placeKey: String {
        return _placeKey
    }
    
    var address: String {
        return _address
    }
    
    var category: String {
        return _category
    }
    
    var latitude: String {
        return _latitude
    }
    
    var longitude: String {
        return _longitude
    }
    
    var name: String {
        return _name
    }
    
    var drivedistance: String {
        return _drivedistance
    }
    
    var eventid: String {
        return _eventid
    }
    
    var eventdate: String {
        return _eventdate
    }
    
    var eventname: String {
        return _eventname
    }
    
    var eventtime: String {
        return _eventtime
    }
    
    var image_url: String {
        return _image_url
    }
    
    // Initialize
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._placeKey = key
        
        // Within the placeID, or Key, the following properties are children
        if let address = dictionary["address"] as? String {
            self._address = address
        }
        
        if let category = dictionary["category"] as? String {
            self._category = category
        }
        
        if let latitude = dictionary["latitude"] as? String {
            self._latitude = latitude
        }
        
        if let longitude = dictionary["longitude"] as? String {
            self._longitude = longitude
        }
        
        if let name = dictionary["name"] as? String {
            self._name = name
        }
        
        if let drivedistance = dictionary["drivedistance"] as? String {
            self._drivedistance = drivedistance
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
        
        if let image_url = dictionary["image_url"] as? String {
            self._image_url = image_url
        }
    }
}
