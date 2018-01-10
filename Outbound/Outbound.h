
/**
 SDK Version 1.0.3
 
 Outbound sends automated email, SMS and push notifications
 based on the actions users take or do not take in your app. The Outbound API 
 has two components:
 
 Identify each of your users and their attributes using an identify API call.
 Track the actions that each user takes in your app using a track API call.
 Because every message is associated with a user (identify call) and a specific 
 trigger action that a user took or should take (track call), Outbound is able 
 to keep track of how each message affects user actions in your app. 
 These calls also allow you to target campaigns and customize each message 
 based on user data.
 
 Example: When a user in San Francisco (user attribute) does signup (event)
 but does not upload a picture (event) within 2 weeks, send them an email
 about how they'll benefit from uploading a picture.
 */

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^OBOperationCompletion)(BOOL success);

@interface Outbound : NSObject

/**
 @abstract Initialize the SDK with your Outbound API key.
 
 @discussion To initialize the library, import Outbound.h and call 
 `-initWithPrivateKey:`. In most cases, it makes sense to do this in
 `-application:didFinishLaunchingWithOptions:`.
 
 @param apiKey Your app's Outbound _private_ API key.
 */
+ (void)initWithPrivateKey:(NSString *)apiKey;

/**
 @abstract Enable detailed logging of Outbound SDK operations.
 
 @discussion It is not recommended to enable this option in
 a production app.
 
 @param debug If set to `YES`, theOutbound SDK will output debug 
 messages to the console.
 */
+ (void)setDebug:(BOOL)debug;

/**
 @abstract You identify a user with Outbound each time you create 
 a new user or update an existing user in your system.
 
 @discussion It is recommended that you send as much information
 about the user as possible. Any attribute you send can be used in 
 the messages from Outbound. So, if you send a `first_name`, your email 
 can say, `Hi {{first_name}}!`
 
 @param userId The unique identifier used to identify this user
 @param attributes A dictionary of attributes associated with the user:

- first_name: "The user's first name" (Optional)
- last_name: "The user's last name" (Optional)
- email: "The user's email address" (Optional - required to send emails)
- phone_number: "The user's phone number" (Optional - required to send sms or make phone calls)
- attributes: { } An optional dictionary of free-form properties you want
 to track for the user. It may contain nested fields and fields can be of any type.
 */
+ (void)identifyUserWithId:(NSString *)userId attributes:(nullable NSDictionary *)attributes;

/**
 @abstract Alias the current user to another a new user id.

 @discussion This function is useful when the user id changes but you'd like it to
 reference the same user object.
 
 @param newUserId The new identifier for the current user.
 */
+ (void)alias:(NSString *)newUserId;

/**
 @abstract You can track unlimited events using the Outbound API. Any event you send
 can be used as a trigger event for a message or the goal event of a desired 
 user flow which triggers a message when not completed within a set period of time.
 
 @discussion Example: Following the example from the previous sections,
 the "signup" event acts as a campaign trigger. If the user does not do 
 the desired goal event, "upload a picture" in 2 weeks, Outbound sends 
 your reminder message.
 
 @param properties An optional dictionary of free-form properties you want 
 to track for the event. It may contain nested fields and fields can be of any type.
 
 Example: properties can be metadata of the event. For example timestamp could be 
 a property of the "signup" event and photo resolution could be a property of 
 the "upload a picture" event.
 */
+ (void)trackEvent:(NSString *)event withProperties:(nullable NSDictionary *)properties;

/**
 @abstract If you want your app to send push notifications, you can register the device token 
 for the user independently of an identify call.
 
 @discussion When you register a token you are telling Outbound to send notifications
 to that token. A single user can have multiple tokens for each platform (APNS or GCM). 
 When Outbound sends a push notification all active tokens will receive the notification.
 
 @param deviceToken The NSData token obtained from `UIApplicationDelegate`'s
 `-application:didRegisterForRemoteNotificationsWithDeviceToken:` method.
 */
+ (void)registerDeviceToken:(NSData *)deviceToken;

/**
 @abstract Disable the device's push token to tell Outbound not to send notifications to this device.
 */
+ (void)disableDeviceToken;

/**
 @abstract Sometimes a group of users share some attributes. Rather than adding 
 these attributes to the identify call for each user, add them to the user's 
 identify call as group attributes. 

 @discussion User attributes will override group attributes
 if there is any overlap (`user.city` will take precendence over `group.city`)
 
 @param groupId The unique identifier used to identify this group.
 @param userId The unique identifier used to identify this user.
 @param groupAttributes A dictionary of attributes associated with the group.
 @param userAttributes A dictionary of attributes associated with the user. See
 -identifyUserWithId:attributes:
 */
+ (void)identifyGroupWithId:(NSString *)groupId userId:(NSString *)userId groupAttributes:(nullable NSDictionary *)groupAttributes andUserAttributes:(nullable NSDictionary *)userAttributes;

+ (BOOL)isUninstallTracker:(NSDictionary *)userInfo;
+ (void)handleNotificationWithUserInfo:(NSDictionary *)userInfo completion:(OBOperationCompletion)completion;
+ (void)handleNotificationResponse:(UNNotificationResponse *)response;
+ (void)logout;
@end

NS_ASSUME_NONNULL_END
