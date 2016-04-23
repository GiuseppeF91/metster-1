//
//  Place.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/10/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation
import Firebase


/*
var events =  [String: userevents]()

func set_event(key: String, dictionary: Dictionary<String, AnyObject>){
 events.updateValue(dictionary, forKey: key)
}
 */

class userevents {
    var eventid: String
    var eventname: String
    var eventhost: String
    var eventdesp: String
    var eventdate: String
    var eventtime: String
    init(eid: String, ename: String, ehost: String, edesp: String, edate: String, etime: String) {
        self.eventid = eid
        self.eventname = ename
        self.eventhost = ehost
        self.eventdesp = edesp
        self.eventdate = edate
        self.eventtime = etime
    }
}
