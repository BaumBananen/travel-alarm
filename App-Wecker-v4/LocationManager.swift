//
//  LocationManager.swift
//  S-Bahn Wecker
//
//  Created by Enno Nussbaum on 29.03.23.
//

import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var onLocationUpdate: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            onLocationUpdate?(location)
        }
    }
}
