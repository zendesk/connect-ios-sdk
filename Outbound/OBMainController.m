//
//  OBMainController.m
//  Outbound
//
//  Created by Emilien on 2015-04-19.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBMainController.h"
#import "OBPopupWindow.h"
#import "OBAdminViewController.h"
#import "OBNetwork.h"

@interface OBMainController () <UIAlertViewDelegate>

/**-----------------------------------------------------------------------------
 * @name Private prrperties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract User has already been asked for permissions.
 */
@property (nonatomic) bool askedForPrePermissions;

/**
 @abstract Blocks awating execution once the SDK is initialized.
 */
@property (nonatomic) NSMutableArray *executeAfterInit;

/**-----------------------------------------------------------------------------
 * @name Private methods
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Sets up the admin gesture on the app's main window
 @discussion [GCD](https://developer.apple.com/library/prerelease/mac/documentation/Performance/Reference/GCD_libdispatch_Ref/index.html)'s dispatch_async function is used to make sure we perform this operation on the app's UI thread.
 */
- (void)setupAdminGesture;

/**
 @abstract This method is called by the UILongPressGestureRecognizer added to the app's main window whenever it is triggered.
 @param gesture The gesture that was triggered
 */
- (void)adminGestureTriggered:(UILongPressGestureRecognizer *)gesture;

- (void)registerForPush;

@end

@implementation OBMainController

#pragma mark - Initialization

// Singleton
+ (OBMainController *)sharedInstance {
    OBSingleton(^{
        return [[self alloc] init];
    });
}

- (void)initWithPrivateKey:(NSString *)apiKey {
    
    // API key
    self.apiKey = apiKey;
    if (!self.apiKey) {
        OBDebug(@"Failed to start Outbound: No API key");
        return;
    }

    // Fetch and cache config.
    [OBConfig getSdkConfigWithCompletion:^(OBConfig *config) {
        self.config = config;
        
        if (self.config) {
            
            if (self.config.remoteKill) {
                OBDebug(@"The SDK is disabled due to remote kill");
            } else {
                if (self.config.promptAtInstall) {
                    [self promptForPermissions];
                }
                if (self.config.pushToken) {
                    self.callsCache.pushToken = self.config.pushToken;
                }
                
                // Initialize calls cache
                self.callsCache = [OBCallsCache callsCache];
                
                // Admin panel gesture
                [self setupAdminGesture];
                
                OBDebug(@"Started Outbound with key %@", self.apiKey);
                
                // Execute instructions that were wating for init to complete
                if (self.executeAfterInit && [self.executeAfterInit count] > 0) {
                    for (void (^block)() in self.executeAfterInit) {
                        block();
                    }
                }
                self.executeAfterInit = nil;
            }
        }
    }];
}

- (void)checkForSdkInitAndExecute:(void (^)())block {
    // Because the init method needs to make a network call before anything else can happen,
    // we need to delay any subsequent calls until we get a response.
    if (self.config) {
        // Has config
        if (self.config.remoteKill) {
            OBDebug(@"The SDK is disabled due to remote kill");
            return;
        } else {
            block();
        }
    } else {
        // No config yet, store block and wait
        if (!self.executeAfterInit) {
            self.executeAfterInit = [NSMutableArray array];
        }
        [self.executeAfterInit addObject:block];
    }
}

#pragma mark - Push permissions
- (void)promptForPermissions {
    // We will ask for permissions only if we do not have permissions already
    // and have not already asked the user this session.
    
    // If the user already gave us permissions, and then the app goes into the background,
    // when this function is called again, we wouldn't have asked for permissions
    // in the new session and we wouldn't have push token because
    // application:didRegisterForRemoteNotification: would not have been called in this
    // session as well. So, we check if we already have permissions.
    if (!self.askedForPrePermissions && !self.callsCache.pushToken && !self.config.hasBeenPrompted) {
        if (self.config.prePrompt) {
            // Display the pre-permission prompt
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:self.config.prePrompt[@"title"], OBClientName] message:self.config.prePrompt[@"body"] delegate:self cancelButtonTitle:self.config.prePrompt[@"no_button"] otherButtonTitles:self.config.prePrompt[@"yes_button"], nil];   This is risky because it relies on the fact the the user-defined string "title" contains a %@ format, otherwise app will crash.
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.config.prePrompt[@"title"] message:self.config.prePrompt[@"body"] delegate:self cancelButtonTitle:self.config.prePrompt[@"no_button"] otherButtonTitles:self.config.prePrompt[@"yes_button"], nil];
            [alert show];
        } else {
            [self registerForPush];
        }
    }
    self.askedForPrePermissions = true;
}

// Delegate method for the pre-permission alert dialog
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If the user pressed YES, for giving push notification permissions.
    if (buttonIndex == 1) {
        [self registerForPush];
    }
}

// Display the actual iOS prompt to ask permission for push notifications
- (void)registerForPush {
    if (!self.config.hasBeenPrompted) {
        UIApplication* app = [UIApplication sharedApplication];
        if ([app respondsToSelector:@selector(registerForRemoteNotifications)]) {
            // iOS 8+
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
            [app registerUserNotificationSettings:settings];
            [app registerForRemoteNotifications];
        } else {
            // iOS < 8
            [app registerForRemoteNotificationTypes:
             UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        }
        [self.callsCache addCall:@"i/ios/permissions/requested" withParameters:nil];
        self.config.hasBeenPrompted = true;
    }
}

- (void)registerDeviceToken:(NSData *)deviceToken {
    if (deviceToken && [deviceToken isKindOfClass:[NSData class]]) {
        NSString *stringToken;
        
        if (deviceToken) {
            NSMutableString *mutableStringToken = [[NSMutableString alloc] init];

            [deviceToken enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
                for (int i = 0; i < byteRange.length; i++) {
                    [mutableStringToken appendFormat:@"%02x", ((uint8_t *)bytes)[i]];
                }
            }];

            stringToken = [mutableStringToken copy];
        } else {
            stringToken = self.config.pushToken;
        }

        self.callsCache.pushToken = stringToken;
        [self.callsCache addCall:@"v2/apns/register" withParameters:@{@"token": stringToken}];
        [self.callsCache addCall:@"i/ios/permissions/granted" withParameters:nil];
        self.config.pushToken = stringToken;
    }
}

#pragma mark - Admin panel gesture

- (void)setupAdminGesture {
    // Admin panel only available on iOS7+
    if (OBIsIOS7) {
        // Setup admin gesture in the main window
        // [GCD](https://developer.apple.com/library/prerelease/mac/documentation/Performance/Reference/GCD_libdispatch_Ref/index.html)'s dispatch_async function is used to make sure we perform this operation on the app's UI thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(adminGestureTriggered:)];
            gesture.cancelsTouchesInView = YES;
            
            // We're using constants for these options to provide different values for the simulator and a real device.
            // See Outbound-Prefix.pch
            gesture.numberOfTouchesRequired = OBAdminGestureTouches;
            gesture.minimumPressDuration = OBAdminGestureDuration;
            
            // The gesture recognizer is added to the app's main window.
            [[UIApplication sharedApplication].keyWindow addGestureRecognizer:gesture];
        });
    }
}

- (void)adminGestureTriggered:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        OBDebug(@"Admin");
        
        [self registerForPush];
        // Show popup window
        OBAdminViewController *adminVc = [[OBAdminViewController alloc] init];
        [adminVc.popup presentPopupAnimated:YES];
    }
}

@end
