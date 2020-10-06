//
//  AppDelegate.swift
//  Alarmation
//
//  Created by Stanly Shiyanovskiy on 06.10.2020.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let center = UNUserNotificationCenter.current()

        if let navController = window?.rootViewController as? UINavigationController {
            if let viewController = navController.viewControllers[0] as? ViewController {
                center.delegate = viewController
            }
        }

        let show = UNNotificationAction(identifier: "show", title: "Show Group", options: .foreground)
        let destroy = UNNotificationAction(identifier: "destroy", title: "Destroy Group", options: [.destructive, .authenticationRequired])
        let rename = UNTextInputNotificationAction(identifier: "rename", title: "Rename Group", options: [], textInputButtonTitle: "Rename", textInputPlaceholder: "Type the new name here")
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, rename, destroy], intentIdentifiers: [], options: [.customDismissAction])

        center.setNotificationCategories([category])

        return true
    }
}

