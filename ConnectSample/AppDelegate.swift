//
//  AppDelegate.swift
//  ConnectSample
//
//  Created by Alan Egan on 19/06/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Outbound.setDebug(true)
        
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().delegate = self
        Outbound.initWithPrivateKey("32735b0ad93aaaf59e1e1bbb4e8a438a")
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Application registered for remote notifications (token: \(deviceToken)")
        Outbound.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Application failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Outbound.handleNotification(userInfo: userInfo) { success in
            completionHandler(success ? .newData : .failed)
        }
        
        if Outbound.isUninstallTracker(userInfo) == false {
            // Handle notifications here.
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Outbound.handle(response)
        completionHandler()
        
        UINavigationBar.appearance().tintColor = .red
        
    }
}

