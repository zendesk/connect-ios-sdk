/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "Outbound.h"
#import "OBMainController.h"
#import "OBCallsCache.h"

#import <UserNotifications/UserNotifications.h>
#import <ZendeskConnect/ZendeskConnect-Swift.h>

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
    ZCNConnect *connect = [OBMainController sharedInstance].connect;
    ZCNUser * user = [[ZCNUser alloc] initWithFirstName:attributes[@"first_name"]
                                                         lastName:attributes[@"last_name"]
                                                            email:attributes[@"email"]
                                                       attributes:attributes[@"attributes"]
                                                           userId:userId
                                                       previousId:connect.currentUser.userId
                                                      phoneNumber:attributes[@"phone_number"]
                                                          groupId:nil
                                                  groupAttributes:nil
                                                         timezone:attributes[@"timezone"]
                                                              gcm:attributes[@"gcm"]
                                                             apns:attributes[@"apns"]];
    
    [connect identifyWithUser:user];
    OBMainController *mc = [OBMainController sharedInstance];
    mc.callsCache.userId = userId;
    
    [mc checkForSdkInitAndExecute:^{
        if (mc.config.promptAtInstall) {
            [mc promptForPermissions];
        }
    }];
}

+ (void)alias:(NSString *)newUserId {
    OBMainController *mc = [OBMainController sharedInstance];
    ZCNUser * user = [ZCNUser aliasWithPreviousUser:mc.connect.currentUser newId:newUserId];
    [mc.connect identifyWithUser:user];
    
    [mc checkForSdkInitAndExecute:^{
        if (mc.config.promptAtInstall) {
            [mc promptForPermissions];
        }
    }];
}

+ (void)trackEvent:(NSString *)event withProperties:(NSDictionary *)properties {
    OBMainController *mc = [OBMainController sharedInstance];
    ZCNEvent *trackEvent = [[ZCNEvent alloc] initWithUserId:mc.connect.currentUser.userId
                                                 properties:properties
                                                      event:event];
    [mc.connect trackWithEvent:trackEvent];
    
    [mc checkForSdkInitAndExecute:^{
        // Ask for push notification permissions if appropriate.
        if (mc.config.promptAtEvent && [mc.config.promptAtEvent isEqualToString:event]) {
            [mc promptForPermissions];
        }
    }];
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    ZCNConnect *connect = [OBMainController sharedInstance].connect;
    [self getNotificationAuthorizationStatusWithCompletion:^(BOOL isAuthorized) {
        // We want to send the token to Outbound only if the user gives permissions. If they don't
        // the token will still come through for "background app refresh", but it's not a real token.
        if (isAuthorized) {
            [connect registerPushToken:deviceToken];
            [[OBMainController sharedInstance].callsCache addCall:@"i/ios/permissions/granted" withParameters:nil];
        }
    }];
}

+ (void)disableDeviceToken {
    OBMainController *mc = [OBMainController sharedInstance];
    if (mc.config.pushToken != nil) {
        [mc.connect disablePushToken];
        mc.config.pushToken = nil;
    }
}

+ (void)identifyGroupWithId:(NSString *)groupId userId:(NSString *)userId groupAttributes:(NSDictionary *)groupAttributes andUserAttributes:(NSDictionary *)userAttributes {
    
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

    ZCNConnect *connect = [OBMainController sharedInstance].connect;
    ZCNUser * user = [[ZCNUser alloc] initWithFirstName:parameters[@"first_name"]
                                                         lastName:parameters[@"last_name"]
                                                            email:parameters[@"email"]
                                                       attributes:parameters[@"attributes"]
                                                           userId:userId
                                                       previousId:nil
                                                      phoneNumber:parameters[@"phone_number"]
                                                          groupId:parameters[@"group_id"]
                                                  groupAttributes:parameters[@"group_attributes"]
                                                         timezone:parameters[@"timezone"]
                                                              gcm:parameters[@"gcm"]
                                                             apns:parameters[@"apns"]];
    
    [connect identifyWithUser:user];
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

+ (BOOL)isOutboundNotification:(NSDictionary *)userInfo {
    // All outbound push notifications, uninstall trackers, or otherwise have _oid.
    return userInfo[OBNotificationUserInfoKeyIdentifier] != nil || userInfo[OBNotificationUserInfoKeyOTM] != nil || userInfo[OBNotificationUserInfoKeyOGP] != nil;
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

    if (![self isOutboundNotification:userInfo]) {
        completion(YES);
        return;
    }

    OBMainController *mc = [OBMainController sharedInstance];
    if (mc.config && [mc.config remoteKill]) {
        OBDebug(@"The SDK is disabled due to remote kill.");
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
    [mc.connect logout];
}

@end
