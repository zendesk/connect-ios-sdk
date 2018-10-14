/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <UserNotifications/UserNotifications.h>

#import "OBMainController.h"
#import "OBPopupWindow.h"
#import "OBAdminViewController.h"
#import "OBNetwork.h"

#import <ZendeskConnect/ZendeskConnect-Swift.h>

static NSString * const OBUserDefaultPrePermissionsGrantedKey = @"_ob_prepermissions_granted";

@interface OBMainController () <UIAlertViewDelegate>

/**-----------------------------------------------------------------------------
 * @name Private properties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract User has already been asked for permissions.
 */
@property (nonatomic) BOOL askedForPrePermissions;

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
    
    self.connect = [[ZCNConnect alloc] initWithEnvironmentKey:apiKey];

    // Fetch and cache config.
    [OBConfig getSdkConfigWithCompletion:^(OBConfig *config) {
        self.config = config;
        
        if (self.config) {
            if (self.config.remoteKill) {
                OBDebug(@"The SDK is disabled due to remote kill.");
            } else {
                // Initialize calls cache
                self.callsCache = [OBCallsCache callsCache];

                // Admin panel gesture
                [self setupAdminGesture];
                
                OBDebug(@"Started Outbound with key %@", self.apiKey);
                
                // Execute instructions that were wating for init to complete
                if (self.executeAfterInit && [self.executeAfterInit count] > 0) {
                    for (OBDeferredExecution block in self.executeAfterInit) {
                        block();
                    }
                }
                self.executeAfterInit = nil;
            }
        }
    }];
}

- (void)checkForSdkInitAndExecute:(OBDeferredExecution)block {
    // Because the init method needs to make a network call before anything else can happen,
    // we need to delay any subsequent calls until we get a response.
    if (self.config) {
        // Has config
        if (self.config.remoteKill) {
            OBDebug(@"The SDK is disabled due to remote kill.");
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasAcceptedPreprompt = [defaults boolForKey:OBUserDefaultPrePermissionsGrantedKey];
    
    // 5 states:
    // - No preprompt -> just call [self registerForPush];
    //   - self.config.prePrompt = NO
    // - Preprompt and not displayed since last app launch -> Show preprompt
    //   - self.config.prePrompt = YES
    //   - self.askedForPrePermissions = NO
    // - Preprompt and been displayed before and rejected -> Do nothing
    //   - self.config.prePrompt = YES
    //   - self.askedForPrePermissions = YES
    //   - hasAcceptedPreprompt = NO
    // - Preprompt and been displayed before and accepted -> just call [self registerForPush];
    //   - self.config.prePrompt = YES
    //   - self.askedForPrePermissions = YES
    //   - hasAcceptedPreprompt = YES
    // - Preprompt and been displayed in previous app launch and accepted -> just call [self registerForPush];
    //   - self.config.prePrompt = YES
    //   - self.askedForPrePermissions = NO
    //   - hasAcceptedPreprompt = YES
    
    if (!self.config.prePrompt) {
        [self registerForPush];
        return;
    }
    
    if (hasAcceptedPreprompt) {
        [self registerForPush];
        return;
    }
    
    if (!self.askedForPrePermissions) {
        // Display the pre-permission prompt
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.config.prePrompt[@"title"] message:self.config.prePrompt[@"body"] delegate:self cancelButtonTitle:self.config.prePrompt[@"no_button"] otherButtonTitles:self.config.prePrompt[@"yes_button"], nil];
        [alert show];
        
        self.askedForPrePermissions = YES;
    }
}


// Delegate method for the pre-permission alert dialog
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // If the user pressed YES, for giving push notification permissions.
    if (buttonIndex == 1) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:OBUserDefaultPrePermissionsGrantedKey];
        [defaults synchronize];
        
        [self registerForPush];
    }
}

// Display the actual iOS prompt to ask permission for push notifications
- (void)registerForPush {
    UIApplication *app = [UIApplication sharedApplication];

    if(@available(iOS 10.0, *)) {
        UNAuthorizationOptions authorizationOptions = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authorizationOptions completionHandler:^(__unused BOOL granted, __unused NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [app registerForRemoteNotifications];
            });
        }];
    } else if (@available(iOS 8.0, *)) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
        [app registerUserNotificationSettings:settings];
        [app registerForRemoteNotifications];
    }

    [self checkForSdkInitAndExecute:^{
        [self.callsCache addCall:@"i/ios/permissions/requested" withParameters:nil];
    }];
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
