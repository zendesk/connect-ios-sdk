//
//  Outbound.m
//  Outbound
//
//  Created by Emilien on 2015-04-18.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "Outbound.h"
#import "OBMainController.h"
#import "OBCallsCache.h"

/**
 This class is the public interface of the Outbound SDK.
 */
@implementation Outbound

+ (void)initWithPrivateKey:(NSString *)apiKey{
    OBMainController *mc = [OBMainController sharedInstance];
    [mc initWithPrivateKey:apiKey];
}

+ (void)setDebug:(BOOL)debug {
    [[OBMainController sharedInstance] setDebug:debug];
}

+ (void)identifyUserWithId:(NSString *)userId attributes:(NSDictionary *)attributes {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        // Checking for class is important here because pointers are integers
        if (userId && [userId isKindOfClass:[NSString class]]) {
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:attributes];
            mc.callsCache.userId = userId;
            params[@"timezone"] = [[NSTimeZone systemTimeZone] name];
            [mc.callsCache addCall:@"v2/identify" withParameters:params];
        }
    }];
}

+ (void)alias:(NSString *)newUserId {
    OBMainController *mc = [OBMainController sharedInstance];
    // Get previous_id from callsCache
    NSString* prevId;
    if (mc.callsCache.userId) {
        prevId = mc.callsCache.userId;
    } else if (mc.callsCache.tempUserId) {
        prevId = mc.callsCache.tempUserId;
    }
    
    mc.callsCache.userId = newUserId;
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:newUserId, @"user_id", nil];
    if (prevId) {
        [attributes setValue:prevId forKey:@"previous_id"];
    }
    [mc.callsCache addCall:@"v2/identify" withParameters:attributes];
}

+ (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        // Make sure a valid string event was passed
        if (event && [event isKindOfClass:[NSString class]]) {
            // Create the params dict for the API call with the event and its properties
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"event"] = event;
            if (properties && [properties isKindOfClass:[NSDictionary class]]) {
                parameters[@"properties"] = properties;
            }
            [mc.callsCache addCall:@"v2/track" withParameters:parameters];
            
            // Ask for push notification permissions if appropriate.
            if (mc.config.promptAtEvent && [mc.config.promptAtEvent isEqualToString:event]) {
                [mc promptForPermissions];
            }
        }
    }];
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        // We want to send the token to Outbound only if the user gives permissions. If they don't
        // the token will still come through for "background app refresh", but it's not a real token.
        bool hasPushPermissions = true;
        UIApplication *app = [UIApplication sharedApplication];
        if ([app respondsToSelector:@selector(currentUserNotificationSettings)] &&
            [app currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
            hasPushPermissions = false;
        }
        
        if (hasPushPermissions) {
            [mc registerDeviceToken:deviceToken];
        }
    }];
}

+ (void)disableDeviceToken {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        if (mc.callsCache.pushToken) {
            [mc.callsCache addCall:@"v2/apns/disable" withParameters:@{@"token": mc.callsCache.pushToken}];
            mc.callsCache.pushToken = nil;
        }
    }];
}

+ (void)identifyGroupWithId:(NSString *)groupId userId:(NSString *)userId groupAttributes:(NSDictionary *)groupAttributes andUserAttributes:(NSDictionary *)userAttributes {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        if (groupId && [groupId isKindOfClass:[NSString class]] && userId && [userId isKindOfClass:[NSString class]]) {
            // Create the params dict for the API call with the group ID, its attributes, and user attributes
            // The user ID is added separately by OBCallsCache when necessary
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"group_id"] = groupId;
            if (groupAttributes && [groupAttributes isKindOfClass:[NSDictionary class]]) {
                parameters[@"group_attributes"] = groupAttributes;
            }
            
            if (userAttributes && [userAttributes isKindOfClass:[NSDictionary class]]) {
                parameters[@"attributes"] = [NSMutableDictionary dictionaryWithDictionary:userAttributes];
            } else {
                parameters[@"attributes"] = [NSMutableDictionary dictionary];
            }
            parameters[@"attributes"][@"timezone"] = [[NSTimeZone systemTimeZone] name];
            
            mc.callsCache.userId = userId;
            [mc.callsCache addCall:@"v2/identify" withParameters:parameters];
        }
    }];
}

// This function actually gets called from `application:didReceiveRemoteNotification:fetchCompletionHandler:`
// which gets called twice. Once when the device receives the push notification (app.applicationState is `UIApplicationStateBackground`)
// and then optionally asecond time if the user clicks the push notification (app.applicationState is `UIApplicationStateInactive`)
+ (void)processNotificationWithUserInfo:(NSDictionary *)userInfo completion:(OBProcessNotificationCompletion)completion
{
    NSParameterAssert(completion != nil);

    // All outbound push notifications, uninstall trackers, or otherwise have _oid.
    if (![userInfo objectForKey:@"_oid"] && ![userInfo objectForKey:@"_otm"]) {
        completion(NO, YES);
        return;
    }

    OBMainController *mc = [OBMainController sharedInstance];
    if (mc.config && [mc.config remoteKill]) {
        OBDebug(@"The SDK is disabled due to remote kill");
        completion(YES, YES);
        return;
    }

    UIApplication *app = [UIApplication sharedApplication];
    
    // Does the app still have permissions to receive and display
    // user visible notifications?
    BOOL hasPushPermissions = YES;
    if ([app respondsToSelector:@selector(currentUserNotificationSettings)] &&
        [app currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
        hasPushPermissions = NO;
    }

    void (^callCompleted)(BOOL) = ^(BOOL success) {
        completion(YES, success);
    };

    // Is this an uninstall tracker?
    if (userInfo[@"_ogp"]) {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        if ([userInfo objectForKey:@"_oid"]) {
            [ret setObject:userInfo[@"_oid"] forKey:@"i"];
        }
        
        if (!hasPushPermissions) {
            [ret setValue:@YES forKey:@"revoked"];
        }
        
        [mc checkForSdkInitAndExecute:^{
            // Tell the server that we received the uninstall tracker.
            [mc.callsCache addCall:@"i/ios/uninstall_tracker" withParameters:ret completion:callCompleted];
        }];
    } else if (hasPushPermissions) {
        // Any other push notification -- pingback
        
        [mc checkForSdkInitAndExecute:^{
            switch (app.applicationState) {
            case UIApplicationStateInactive:
                // If the notification has a deeplink url, the we go there.
                if (userInfo[@"_odl"] != nil) {
                    NSURL *url = [NSURL URLWithString:userInfo[@"_odl"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([app canOpenURL:url]) {
                            [app openURL:url];
                        }
                    });
                }

                [mc.callsCache addCall:@"i/ios/opened" withParameters:userInfo completion:callCompleted];

                break;
            case UIApplicationStateBackground:
                // Push notification just received. App has not been opened yet.
                [mc.callsCache addCall:@"i/ios/received" withParameters:userInfo completion:callCompleted];

                break;
            default:
                completion(YES, NO);
                break;
            }
        }];
    } else {
        completion(YES, NO);
    }
}

+ (void)logout {
    OBMainController* mc = [OBMainController sharedInstance];
    mc.callsCache.userId = @"";
    mc.callsCache.tempUserId = @"";
}
@end
