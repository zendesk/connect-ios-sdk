//
//  OBCall.h
//  Outbound
//
//  Created by Emilien on 2015-04-20.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The OBCall object is used by the OBCallsCache to store the necessary information for one call to the [Outbound API](https://github.com/outboundio/api).
 It conforms to the [NSCoding protocol](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/index.html) to be easily archived by the OBCallsCache.
 */
@interface OBCall : NSObject <NSCoding>

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract The user ID associated with the call.
 @discussion The user ID needs to be stored for each call in case the user logs out and logs back in with another user ID.
 */
@property (nonatomic) NSString *userId;

/**
 @abstract The temporary user ID assigned to the call if no user ID is present.
 @discussion If the user logs in after this call is stored, the new user ID is assigned to this call's userId property, and this tempUserId is ignored.
 */
@property (nonatomic) NSString *tempUserId;

/**
 @abstract API call POST parameters.
 @discussion The call parameters usually don't include a user ID. userId or tempUserId is inserted for key `user_id` when the request is being made, in order to make sure that it is up to date.
 */
@property (nonatomic) NSDictionary *parameters;

/**
 @abstract API call path.
 @discussion Possible paths as defined by the [Outbound API](https://github.com/outboundio/api) are `identify`, `track`, `apns/register`, `apns/disable`.
 */
@property (nonatomic) NSString *path;

/**
 @abstract Timestamp of the call creation date.
 */
@property (nonatomic) NSTimeInterval timestamp;

/**-----------------------------------------------------------------------------
 * @name Instance methods
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Performs the network request corresponding to the call object.
 @param completion The completion block to be executed on completion of the network request. The `mustRetry` boolean parameter will indicate that the server has responded HTTP>=500, or hasn't responded at all (HTTP 0) in which case the request must be attempted again.
 */
- (void)sendCallWithCompletion:(void (^)(BOOL mustRetry))completion;

@end
