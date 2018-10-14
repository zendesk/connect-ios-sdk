/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef enum : NSInteger {
    OBNotReachable = 0,
    OBReachableViaWiFi,
    OBReachableViaWWAN
} OBNetworkStatus;

/**
 Notification broadcasted whenever the reachability status changes if the notifier has been started.
 */
extern NSString *kOBReachabilityChangedNotification;

/**
 Apple's [Reachability](https://developer.apple.com/library/ios/samplecode/Reachability/Introduction/Intro.html) class renamed OBReachability to avoid collisions in case the host app uses Reachability.
 */
@interface OBReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;

/*!
 * Stop listening for reachability notifications.
 */
- (void)stopNotifier;

/*!
 * Returns the current network status.
 */
- (OBNetworkStatus)currentReachabilityStatus;

/*!
 * Helper method to combile -currentReachabilityStatus and -connectionRequired to get a meaningful OBNetworkStatus.
 */
- (OBNetworkStatus)networkStatus;

/*!
 * Helper method to display a OBNetworkStatus value in the console.
 * @param status The OBNetworkStatus value to display
 */
+ (void)printNetworkStatus:(OBNetworkStatus)status;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

@end
