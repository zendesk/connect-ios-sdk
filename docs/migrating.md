# Migrating from Outbound iOS SDK 1.0.X to 1.1.X

The upgrade from 1.0.X to 1.1.X includes:
- Improvements for iOS 10+
- Changes to our SDK's notification API

## Objective-C

### AppDelegate.m

Before:
```objectivec
#import "AppDelegate.h"
#import <Outbound/Outbound.h>

@implementation AppDelegate

// ...

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([Outbound isUninstallTracker:userInfo]) {
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        // HANDLE YOUR BACKGROUND PUSH NOTIFICATIONS HERE
        completionHandler(UIBackgroundFetchResultNewData);
    }
}
```

After:
```objectivec
#import "AppDelegate.h"
#import <Outbound/Outbound.h>
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ...
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    // ...
}

// ...

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([Outbound isOutboundNotification:userInfo]) {
        [Outbound handleNotificationWithUserInfo:userInfo completion:^(BOOL success) {
            completionHandler(success ? UIBackgroundFetchResultNewData : UIBackgroundFetchResultFailed);
        }];
    } else {
        // Hande non-Outbound notifications here
        completionHandler(UIBackgroundFetchResultNoData);
    }
}

// iOS 10+ specific callbacks
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    // Optionally allow showing notifications while the app is in the foreground.
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionBadge);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    [Outbound handleNotificationResponse:response];
    completionHandler();
}
```

## Swift

### AppDelegate.swift

Before:
```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    Outbound.initWithPrivateKey("...")
    return true
  }

  // ...

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (_: UIBackgroundFetchResult) -> Void) {
    if (Outbound.isUninstallTracker(userInfo)) {
      completionHandler(.newData);
    } else {
      // HANDLE YOUR BACKGROUND PUSH NOTIFICATIONS HERE
      completionHandler(.newData);
    }
  }

  // ...
}
```

After:
```swift
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    Outbound.initWithPrivateKey("...")
    return true
  }

  // ...

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if (Outbound.isOutboundNotification(userInfo)) {
      Outbound.handleNotification(userInfo: userInfo, completion: {(_ success: Bool) -> Void in
        completionHandler(success ? .newData : .failed)
      })
    } else {
      // Handle notifications here.
      completionHandler(.newData);
    }
  }

  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      // Optionally allow showing notifications while the app is in the foreground.
      completionHandler([.alert, .sound, .badge])
  }

  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      Outbound.handle(response)
      completionHandler()
  }
}
```