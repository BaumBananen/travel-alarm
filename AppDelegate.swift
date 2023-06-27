//
//  AppDelegate.swift
//  S-Bahn Wecker
//
//  Created by Enno Nussbaum on 29.03.23.
//

import UIKit
import UserNotifications
import SwiftUI


class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request permission to display alerts and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                // Register for remote notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        // Create the main window and set the root view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        let contentView = ContentView()
        window?.rootViewController = UIHostingController(rootView: contentView)
        window?.makeKeyAndVisible()
        
        // Set UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

// Conform to UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           willPresent notification: UNNotification,
           withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
}
