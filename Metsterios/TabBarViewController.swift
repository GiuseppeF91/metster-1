//
//  TabBarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var profileVC : ProfileViewController?
    var preferencesVC : PreferencesViewController?
    var addEventVC : AddEventViewController?
    var calendarVC : CalendarViewController?
    var chatVC : ChatViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.whiteColor()
    
        profileVC = ProfileViewController()
        preferencesVC = PreferencesViewController()
        addEventVC = AddEventViewController()
        calendarVC = CalendarViewController()
        chatVC = ChatViewController()
        
        self.viewControllers = [profileVC! , preferencesVC! , addEventVC!, calendarVC!, chatVC!]
        
        let profile = UITabBarItem(title: "Profile", image: nil, tag: 0)
        let pref = UITabBarItem(title: "Pref", image: nil, tag: 1)
        let add = UITabBarItem(title: "Add", image: nil, tag: 2)
        let cal = UITabBarItem(title: "Cal", image: nil, tag: 3)
        let chat = UITabBarItem(title: "Chat", image: nil, tag: 4)
        
        self.selectedIndex = 3
       
        profileVC?.tabBarItem = profile
        preferencesVC?.tabBarItem = pref
        addEventVC?.tabBarItem = add
        calendarVC?.tabBarItem = cal
        chatVC?.tabBarItem = chat
    }
}
