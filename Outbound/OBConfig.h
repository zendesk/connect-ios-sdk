//
//  OBConfig.h
//  Outbound
//
//  Created by Dhruv on 2015-06-17.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

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
