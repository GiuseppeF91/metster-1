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
    var name:String = ""

    init(data:NSDictionary)
    {
        
        if let add = data["colorName"] as? String
        {
            self.name = add
        }
        
    }
}
