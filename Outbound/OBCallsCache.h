//
//  OBCallsCache.h
//  Outbound
//
//  Created by Emilien on 2015-04-19.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Outbound.h"
#import "OBReachability.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 The OBCallsCache class is a cache layer that abstracts away the caching logic for Outbound API network calls. It monitors the device's network status and decides when to perform network requests and when to store them to disk. It also stores the user ID and the device's push token and adds them to request parameters when necessary.
 It conforms to the [NSCoding protocol](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/index.html) to be persisted to disk.
 */
@interface OBCallsCache : NSObject

/**-----------------------------------------------------------------------------
 * @name Properties
 * -----------------------------------------------------------------------------
 */

/**
 @abstract The current user ID
 @discussion userId is obtained after a call to Outbound -identifyUserWithId:attributes: or -identifyGroupWithId:userId:groupAttributes:andUserAttributes:. When a new userId is set, one of two things will happen.
 - If we previously had a different userId, it means that user was logged out, so we unregister his push token by calling the API endpoint `apns/disable`.
 - If we didn't have a userId, but we had a tempUserId, then all the previously stored calls without a userId will get this userId. A call to the API endpoint `identify` is also made to link the tempUserId to the new userId.
 
 userId is persisted to the cache file so that it is available on subsequent app launches.
*/
@property (nullable, nonatomic) NSString *userId;

/**
 @abstract A temporary user ID created by the SDK to track calls before a user is identified.
 @discussion tempUserId is created in -addCall:withParameters: when a userId isn't available. [NSUUID](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSUUID_Class/) is used to create the tempUserId as a unique 128-bit UUID string (e.g. 68753A44-4D6F-1226-9C60-0050E4C00067), which is only available for iOS 6.0+. 
 
 tempUserId is persisted to the cache file so that it is available on subsequent app launches.
 */
@property (nullable, nonatomic) NSString *tempUserId;

/**
 @abstract A list of stored calls that haven't been performed yet.
 @discussion If the host app makes a request using the SDK but network connections are not avaiable, the
 request is stored in this array
 */
@property (nonatomic) NSMutableArray *calls;

/**
 @abstract An instance of OBReachability that listens to network status changes.
 */
@property (nonatomic) OBReachability *reachability;


/**-----------------------------------------------------------------------------
 * @name Public methods
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Constructor for the OBCallsCache object.
 @discussion If a cache file exists in the app's sandbox, then the OBCallsCache is created using [NSCoding](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/index.html)'s -initWithCoder: method. 
 Otherwise an empty OBCallsCache object is created.
 */
+ (OBCallsCache *)callsCache;

/**
 @abstract Adds a call to the queue to be either performed right away (if network available) or stored and performed later (if network unavaiable).
 @discussion The OBCall object is created by this method, which then determines whether to call its sendCallWithCompletion: method, or to store it using saveCall:.
 @param path The path or the API endpoint. Possible paths as defined by the [Outbound API](https://github.com/outboundio/api) are `identify`, `track`, `apns/register`, `apns/disable`.
 @param parameters The call POST parameters.
 */
- (void)addCall:(NSString *)path withParameters:(nullable NSDictionary *)parameters;

- (void)addCall:(NSString *)path withParameters:(nullable NSDictionary *)parameters completion:(nullable OBOperationCompletion)completion;

@end

NS_ASSUME_NONNULL_END
