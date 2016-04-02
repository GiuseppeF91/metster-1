//
//  EventModel.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/1/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation

struct EventModel {
    var address: String?
    var restaurantName: String?
    var eventName: String?

    init(dictionary: [String: AnyObject]) {
        address = dictionary["address"] as? String
        restaurantName = dictionary["restaurantName"] as? String
        eventName = dictionary["eventName"] as? String
    }
}