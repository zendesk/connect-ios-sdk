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

#import <UserNotifications/UserNotifications.h>

static NSString * const OBNotificationUserInfoKeyIdentifier = @"_oid";
static NSString * const OBNotificationUserInfoKeyOTM = @"_otm";
static NSString * const OBNotificationUserInfoKeyDeepLink = @"_odl";
static NSString * const OBNotificationUserInfoKeyOGP = @"_ogp";

/**
 This class is the public interface of the Outbound SDK.
 */
@implementation Outbound

+ (void)initWithPrivateKey:(NSString *)apiKey {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc initWithPrivateKey:apiKey];
}

+ (void)setDebug:(BOOL)debug {
    [OBMainController sharedInstance].debug = debug;
}

+ (void)identifyUserWithId:(NSString *)userId attributes:(NSDictionary *)attributes {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:attributes];
        mc.callsCache.userId = userId;
        params[@"timezone"] = [[NSTimeZone systemTimeZone] name];
        [mc.callsCache addCall:@"v2/identify" withParameters:params];

        if (mc.config.promptAtInstall) {
            [mc promptForPermissions];
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

    [mc checkForSdkInitAndExecute:^{
        [mc.callsCache addCall:@"v2/identify" withParameters:attributes];

        if (mc.config.promptAtInstall) {
            [mc promptForPermissions];
        }
    }];
}

+ (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
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
    }];
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    OBMainController *mainController = [OBMainController sharedInstance];
    [self getNotificationAuthorizationStatusWithCompletion:^(BOOL isAuthorized) {
        // We want to send the token to Outbound only if the user gives permissions. If they don't
        // the token will still come through for "background app refresh", but it's not a real token.
        if (isAuthorized) {
            [mainController checkForSdkInitAndExecute:^{
                [mainController registerDeviceToken:deviceToken];
            }];
        }
    }];
}

+ (void)disableDeviceToken {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
        if (mc.config.pushToken != nil) {
            [mc.callsCache addCall:@"v2/apns/disable" withParameters:@{@"token": mc.config.pushToken}];
            mc.config.pushToken = nil;
        }
    }];
}

+ (void)identifyGroupWithId:(NSString *)groupId userId:(NSString *)userId groupAttributes:(NSDictionary *)groupAttributes andUserAttributes:(NSDictionary *)userAttributes {
    OBMainController *mc = [OBMainController sharedInstance];
    [mc checkForSdkInitAndExecute:^{
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
    }];
}

+ (void)handleNotificationResponse:(UNNotificationResponse *)response {
    NSParameterAssert(response != nil);

    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [self handleDeepLinkForNotificationUserInfo:response.notification.request.content.userInfo completion:nil];
    }
}

+ (void)handleDeepLinkForNotificationUserInfo:(NSDictionary *)userInfo completion:(void (^)(BOOL success))completion {
    NSURL *deepLinkURL = [NSURL URLWithString:userInfo[OBNotificationUserInfoKeyDeepLink]];

    if (deepLinkURL != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[UIApplication sharedApplication] canOpenURL:deepLinkURL]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:deepLinkURL options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:deepLinkURL];
                }
            }
        });
    }

    [[OBMainController sharedInstance] checkForSdkInitAndExecute:^{
        [[OBMainController sharedInstance].callsCache addCall:@"i/ios/opened" withParameters:userInfo completion:completion];
    }];
}

+ (void)getNotificationAuthorizationStatusWithCompletion:(void (^)(BOOL isAuthorized))completion {
    if (@available(iOS 10.0, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(settings.authorizationStatus == UNAuthorizationStatusAuthorized);
            });
        }];
    } else if (@available(iOS 8.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIUserNotificationSettings *notificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
            completion(notificationSettings.types != UIUserNotificationTypeNone);
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
        });
    }
}

+ (BOOL)isUninstallTracker:(NSDictionary *)userInfo {
    return userInfo[OBNotificationUserInfoKeyOGP] != nil;
}

// This function actually gets called from `application:didReceiveRemoteNotification:fetchCompletionHandler:`
// which gets called twice. Once when the device receives the push notification (app.applicationState is `UIApplicationStateBackground`)
// and then optionally asecond time if the user clicks the push notification (app.applicationState is `UIApplicationStateInactive`)
+ (void)handleNotificationWithUserInfo:(NSDictionary *)userInfo completion:(OBOperationCompletion)completion
{
    NSParameterAssert(userInfo != nil);
    NSParameterAssert(completion != nil);

    // All outbound push notifications, uninstall trackers, or otherwise have _oid.
    if (userInfo[OBNotificationUserInfoKeyIdentifier] == nil && userInfo[OBNotificationUserInfoKeyOTM] == nil) {
        completion(YES);
        return;
    }

    OBMainController *mc = [OBMainController sharedInstance];
    if (mc.config && [mc.config remoteKill]) {
        OBDebug(@"The SDK is disabled due to remote kill");
        completion(YES);
        return;
    }
    
    [self getNotificationAuthorizationStatusWithCompletion:^(BOOL isAuthorized) {
        if ([self isUninstallTracker:userInfo]) {
            [self handleUninstallTrackerNotificationWithUserInfo:userInfo isAuthorized:isAuthorized completion:completion];
        } else if (isAuthorized) {
            [self handleStandardNotificationWithUserInfo:userInfo completion:completion];
        } else {
            completion(YES);
        }
    }];
}

+ (void)handleUninstallTrackerNotificationWithUserInfo:(NSDictionary *)userInfo isAuthorized:(BOOL)isAuthorized completion:(OBOperationCompletion)completion {
    OBMainController *mainController = [OBMainController sharedInstance];

    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    NSString *identifier = userInfo[OBNotificationUserInfoKeyIdentifier];

    if (identifier != nil) {
        metadata[@"i"] = identifier;
    }

    if (!isAuthorized) {
        metadata[@"revoked"] = @YES;
    }

    [mainController checkForSdkInitAndExecute:^{
        // Tell the server that we received the uninstall tracker.
        [mainController.callsCache addCall:@"i/ios/uninstall_tracker" withParameters:metadata completion:completion];
    }];
}


+ (void)handleStandardNotificationWithUserInfo:(NSDictionary *)userInfo completion:(OBOperationCompletion)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([UIApplication sharedApplication].applicationState) {
            case UIApplicationStateActive:
                completion(YES);
                break;
            case UIApplicationStateInactive:
                if (@available(iOS 10.0, *)) {
                } else {
                    [self handleDeepLinkForNotificationUserInfo:userInfo completion:completion];
                    break;
                }

            case UIApplicationStateBackground: {
                OBMainController *mainController = [OBMainController sharedInstance];

                 // Push notification just received. App has not been opened yet.
                [mainController checkForSdkInitAndExecute:^{
                    [mainController.callsCache addCall:@"i/ios/received" withParameters:userInfo completion:completion];
                }];

                break;
            }
        }
    });
}

+ (void)logout {
    OBMainController* mc = [OBMainController sharedInstance];
    mc.callsCache.userId = @"";
    mc.callsCache.tempUserId = @"";
}

@end
