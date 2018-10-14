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

/**
 The OBConfig object is used by the SDK to store the necessary global information.
 */
@interface OBConfig : NSObject <NSCoding>

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Whether the SDK should ask for push notification permissions.
 @discussion This decides whether or not the SDK asks for push permissions.
 */
@property (nonatomic) BOOL promptForPermission;

/**
 @abstract If the SDK should prompt when a particular event happens.
 @discussion Typically only either this or `promptAtInstall` will be set.
 */
@property (nonatomic) NSString* promptAtEvent;

/**
 @abstract If the SDK should prompt at install.
 @discussion Typically only either this or `promptAtEvent` will be set.
 */
@property (nonatomic) BOOL promptAtInstall;

/**
 @abstract What the SDK will ask before asking for push permissions.
 @discussion We do this to avoid losing the user completely.
 */
@property (nonatomic) NSDictionary* prePrompt;

@property (nonatomic, copy) NSString* pushToken;
@property (nonatomic) BOOL remoteKill;

/**
 @abstract The date at which the config was last fetched.
 @discussion We will fetch the config again if it was fetched more than an hour ago.
 */
@property (nonatomic) NSDate *fetchDate;

+ (void)getSdkConfigWithCompletion:(void (^)(OBConfig *config))completion;

@end
