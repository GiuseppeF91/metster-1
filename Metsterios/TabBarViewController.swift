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
    var mapViewVC : MapViewController?
    //var mapViewVC : Mapbx?
    var saveButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.whiteColor()
        
        profileVC = ProfileViewController()
        preferencesVC = PreferencesViewController()
        addEventVC = AddEventViewController()
        calendarVC = CalendarViewController()
        mapViewVC = MapViewController()
        //mapViewVC = Mapbx()
        
        self.viewControllers = [profileVC! , preferencesVC! , addEventVC!, calendarVC!, mapViewVC!]
        
        let profile = UITabBarItem(title: "Profile", image: UIImage(named: "tabar"), tag: 0)
        let pref = UITabBarItem(title: "Preference", image: UIImage(named: "preferenceicon"), tag: 1)
        let add = UITabBarItem(title: "New Event", image: UIImage(named: "newicon"), tag: 2)
        let cal = UITabBarItem(title: "Events", image: UIImage(named: "eventicon"), tag: 3)
        let map = UITabBarItem(title: "Map", image: UIImage(named: "mapicon"), tag: 4)
    
        self.selectedIndex = 3
       
        profileVC?.tabBarItem = profile
        preferencesVC?.tabBarItem = pref
        addEventVC?.tabBarItem = add
        calendarVC?.tabBarItem = cal
        mapViewVC?.tabBarItem = map
        
    }
}
