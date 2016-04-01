//
//  Event.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/30/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

var events:[Event] = [Event]()

struct Event
{
    var eventName = ""
    var query = ""
    var event_id = ""
    var event_date = ""
    var event_time = ""
    var event_notes = ""
    var event_members = []

    init(data:NSDictionary)
    {
        
    }
}



