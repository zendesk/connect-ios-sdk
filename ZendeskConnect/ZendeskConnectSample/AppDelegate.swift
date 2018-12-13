/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

import UIKit
import UserNotifications
import ZendeskConnect

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Logger.enabled = true

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        Connect.instance.init(privateKey:"d24426956432b8bc005fff1e51dc6fcf")
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Application registered for remote notifications (token: \(deviceToken))")
        Connect.instance.registerPushToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Application failed to register for remote notifications: \(error.localizedDescription)")
    }


    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if Connect.instance.isConnectNotification(userInfo: userInfo) {
            Connect.instance.handleNotification(userInfo: userInfo) { success in
                completionHandler(success ? .noData : .failed)
                return
            }
        } else {
            completionHandler(.noData)
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Optionally allow showing notifications while the app is in the foreground.
        completionHandler([.alert, .sound, .badge])
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        if Connect.instance.isConnectNotificationResponse(response) {
            Connect.instance.handleNotificationResponse(response, completion: completionHandler)
        } else {
            completionHandler()
        }
    }
}

