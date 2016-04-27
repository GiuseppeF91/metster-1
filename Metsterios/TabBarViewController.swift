//
//  TabBarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Mapbox

class TabBarViewController: UITabBarController, CLLocationManagerDelegate {
    
    var profileVC : ProfileViewController?
    var preferencesVC : PreferencesViewController?
    var addEventVC : AddEventViewController?
    var calendarVC : CalendarViewController?
    var mapViewVC : MapViewController?
    //var mapViewVC : Mapbx?
    var saveButton : UIBarButtonItem!
    
    // location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("====== ENTER TABBAR View Controller =====")
        view.backgroundColor = UIColor.whiteColor()
        
        profileVC = ProfileViewController()
        preferencesVC = PreferencesViewController()
        addEventVC = AddEventViewController()
        calendarVC = CalendarViewController()
        mapViewVC = MapViewController()
        //mapViewVC = Mapbx()
        
        // get map updates
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.viewControllers = [profileVC! , preferencesVC! , mapViewVC!, calendarVC!, addEventVC!]
        
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
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location:CLLocation = locations[locations.count-1]
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            print(location.coordinate)
            let point1 = MGLPointAnnotation()
            let lat = Double(location.coordinate.latitude)
            let lon = Double(location.coordinate.longitude)
            Users.sharedInstance().lat = lat
            Users.sharedInstance().long = lon
            point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            // new location update present location : TODO
            RequestInfo.sharedInstance().postReq("111003")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                })
            }
        }
    }
}
