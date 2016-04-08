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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.whiteColor()
    
        profileVC = ProfileViewController()
        preferencesVC = PreferencesViewController()
        addEventVC = AddEventViewController()
        calendarVC = CalendarViewController()
        
        self.viewControllers = [profileVC! , preferencesVC! , addEventVC!, calendarVC!]
        
        let profile = UITabBarItem(title: "Profile", image: nil, tag: 0)
        let pref = UITabBarItem(title: "Pref", image: nil, tag: 1)
        let add = UITabBarItem(title: "Add", image: nil, tag: 2)
        let cal = UITabBarItem(title: "Events", image: nil, tag: 3)
        
        self.selectedIndex = 1
       
        profileVC?.tabBarItem = profile
        preferencesVC?.tabBarItem = pref
        addEventVC?.tabBarItem = add
        calendarVC?.tabBarItem = cal
    }
}
