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
    //private var _image_url: String!
    private var _latitude: String!
    private var _longitude: String!
    private var _name: String!
    //private var _phone: String!
    //private var _rank: String!
    //private var _ratings: String!
    //private var _review_count: String!
    //private var _snippet: String!
    //private var _url: String!
    private var _eventid: String!
    
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
    
    var eventid: String {
        return _eventid
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
        
        if let eventid = dictionary["eventid"] as? String {
            self._eventid = eventid
        }
    }
}
