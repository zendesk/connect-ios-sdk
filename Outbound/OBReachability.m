/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>
#import "OBReachability.h"

NSString *kOBReachabilityChangedNotification = @"kOBNetworkReachabilityChangedNotification";

#pragma mark - Supporting functions

static void OBReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(__bridge NSObject*) info isKindOfClass: [OBReachability class]],
              ([NSString stringWithFormat:@"info was wrong class in ReachabilityCallback. It was: %@",
               NSStringFromClass([(__bridge NSObject*) info class])]));
    
    OBReachability* noteObject = (__bridge OBReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kOBReachabilityChangedNotification object: noteObject];
}

#pragma mark - Reachability implementation

@implementation OBReachability {
    BOOL _alwaysReturnLocalWiFiStatus; //default is NO
    SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
    OBReachability* returnValue = NULL;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if (reachability != NULL) {
        returnValue= [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
            returnValue->_alwaysReturnLocalWiFiStatus = NO;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress);
    
    OBReachability* returnValue = NULL;
    
    if (reachability != NULL) {
        returnValue = [[self alloc] init];
        if (returnValue != NULL) {
            returnValue->_reachabilityRef = reachability;
            returnValue->_alwaysReturnLocalWiFiStatus = NO;
        } else {
            CFRelease(reachability);
        }
    }
    return returnValue;
}



+ (instancetype)reachabilityForInternetConnection {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}


+ (instancetype)reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    
    OBReachability* returnValue = [self reachabilityWithAddress: &localWifiAddress];
    if (returnValue != NULL) {
        returnValue->_alwaysReturnLocalWiFiStatus = YES;
    }
    
    return returnValue;
}


#pragma mark - Start and stop notifier

- (BOOL)startNotifier {
    BOOL returnValue = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(_reachabilityRef, OBReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            returnValue = YES;
        }
    }
    
    return returnValue;
}


- (void)stopNotifier {
    if (_reachabilityRef != NULL) {
        SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}


- (void)dealloc {
    [self stopNotifier];
    if (_reachabilityRef != NULL) {
        CFRelease(_reachabilityRef);
    }
}


#pragma mark - Network Flag Handling

- (OBNetworkStatus)localWiFiStatusForFlags:(SCNetworkReachabilityFlags)flags {
    OBNetworkStatus returnValue = OBNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        returnValue = OBReachableViaWiFi;
    }
    
    return returnValue;
}


- (OBNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // The target host is not reachable.
        return OBNotReachable;
    }
    
    OBNetworkStatus returnValue = OBNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        returnValue = OBReachableViaWiFi;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = OBReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        returnValue = OBReachableViaWWAN;
    }
    
    return returnValue;
}


- (BOOL)connectionRequired {
    NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    
    return NO;
}


- (OBNetworkStatus)currentReachabilityStatus {
    NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
    OBNetworkStatus returnValue = OBNotReachable;
    SCNetworkReachabilityFlags flags;
    
    if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        if (_alwaysReturnLocalWiFiStatus) {
            returnValue = [self localWiFiStatusForFlags:flags];
        } else {
            returnValue = [self networkStatusForFlags:flags];
        }
    }
    
    return returnValue;
}

- (OBNetworkStatus)networkStatus {
    OBNetworkStatus netStatus = [self currentReachabilityStatus];
    BOOL connectionRequired = [self connectionRequired];
    
    // If the connection is available but requires connection, it is useless to us
    // Treat it as not reachable
    if (connectionRequired) {
        netStatus = OBNotReachable;
    }
    
    return netStatus;
}

+ (void)printNetworkStatus:(OBNetworkStatus)status {
    switch (status) {
        case OBNotReachable:
            OBDebug(@"Network status: Not reachable");
            break;
        case OBReachableViaWiFi:
            OBDebug(@"Network status: Reachable via WiFi");
            break;
        case OBReachableViaWWAN:
            OBDebug(@"Network status: Reachable via WWAN");
            break;
        default:
            break;
    }
}

@end
