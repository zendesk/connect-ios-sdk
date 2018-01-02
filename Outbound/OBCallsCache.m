//
//  OBCallsCache.m
//  Outbound
//
//  Created by Emilien on 2015-04-19.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBCallsCache.h"
#import "OBCall.h"
#import "OBNetwork.h"

// Serialization keys
#define OBCacheUser     @"user"
#define OBCacheTempUser @"tempUser"
#define OBCacheToken    @"token"
#define OBCacheCalls    @"calls"

@interface OBCallsCache ()


/**-----------------------------------------------------------------------------
 * @name Private methods
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Keeps the previous network status value to compare it to the new one whenever -reachabilityChanged: 
 is called, to determine what kind of change we're dealing with.
 */
@property (nonatomic) OBNetworkStatus previousNetworkStatus;

/**
 @abstract The delay after which failed requests are attempted again.
 @discussion This is used for exponential back off. When a request is performed and fails because of a
 server-side error (HTTP >= 500), the request is placed back in the queue and attempted again after a delay, 
 which increases exponentially after each retry. After 10 retries, the call is dropped.
 */
@property (nonatomic) NSInteger retryDelay;

/**
 @abstract The timer object that manages failed requests retries
 */
@property (nonatomic) NSTimer *retryTimer;

/**
 @abstract Sets up OBReachability notifier to listen to changes in the device's network status.
 */
- (void)setup;

/**
 @abstract Called by the OBReachability notifier whenever the device's network status changes. 
 @discussion If the status changed from unavailable to available, then this method calls -sendStoredCalls.
 @param notification The network status change notification
 */
- (void)reachabilityChanged:(NSNotification *)notification;

/**
 @abstract Performs network requests for all cached calls, and flushes the cache.
 */
- (void)sendStoredCalls;

/**
 @abstract Executes a method following an exponential back off pattern, with a maximum of 10 retries.
 @discussion The method is called after a certain delay specified by the property retryDelay, which will be 
 doubled each time. If the delay attains a value of 512 (2^9) the call is cancelled.
 @param The method to execute again
 */
- (void)retryWithExponentialBackOff:(SEL)method;

/**
 @abstract Adds a call to the cache and persists it to disk.
 @param call The call to add to the cache
 */
- (void)saveCall:(OBCall *)call;

/**
 Returns the absolute path of the cache file in the app's sandbox. The cache file is located in the 
 Documents directory and its file name is `outbound.dat`.
 */
+ (NSString *)cacheFilePath;

/**
 @abstract Write the cached properties to the cache file.
 @discussion Cached properties are: userId, tempUserId, pushToken, calls.
 */
- (void)saveCache;


/**-----------------------------------------------------------------------------
 * @name NSCoding protocol
 * -----------------------------------------------------------------------------
 */

/**
 @abstract Deserialize object
 @discussion See [NSCoding protocol](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/index.html)
 */
- (id)initWithCoder:(NSCoder *)coder;

/**
 @abstract Serialize object
 @discussion See [NSCoding protocol](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/index.html)
 */
- (void)encodeWithCoder:(NSCoder *)coder;

@end

@implementation OBCallsCache

#pragma mark - Calls persistance

+ (OBCallsCache *)callsCache {
    OBCallsCache *cache = nil;
    
    // Look for an existing cache file
    NSString *path = [OBCallsCache cacheFilePath];
    OBDebug(@"Cache location %@", path);
    
    if (path && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
        // If the cache file exists, load it
        cache = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    } else {
        // Otherwise create an empty cache
        cache = [[OBCallsCache alloc] init];
        cache.calls = [NSMutableArray array];
    }
    
    // Start Reachability notifier
    [cache setup];
    return cache;
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _userId = [coder decodeObjectForKey:OBCacheUser];
        _tempUserId = [coder decodeObjectForKey:OBCacheTempUser];
        _pushToken = [coder decodeObjectForKey:OBCacheToken];
        _calls = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:OBCacheCalls]];
        
        OBDebug(@"Loaded cache (%@ saved calls)", @([_calls count]));
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:OBCacheUser];
    [coder encodeObject:self.tempUserId forKey:OBCacheTempUser];
    [coder encodeObject:self.pushToken forKey:OBCacheToken];
    [coder encodeObject:self.calls forKey:OBCacheCalls];
}

+ (NSString *)cacheFilePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:@"outbound.dat"];
}

- (void)saveCall:(OBCall *)call {
    [self.calls addObject:call];
    [self saveCache];
}

- (void)saveCache {
    OBDebug(@"Saving cache (%@ calls)", @([self.calls count]));
    [NSKeyedArchiver archiveRootObject:self toFile:[OBCallsCache cacheFilePath]];
}

#pragma mark - Reachability

- (void)setup {
    // Initialize exponential back off
    self.retryDelay = 1;
    
    // Setup network reachability listener
    self.reachability = [OBReachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    // Send cached events if not empty
    self.previousNetworkStatus = [self.reachability networkStatus];
    if (self.previousNetworkStatus != OBNotReachable) {
        [OBReachability printNetworkStatus:self.previousNetworkStatus];
        [self sendStoredCalls];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kOBReachabilityChangedNotification object:nil];
}

- (void)dealloc {
    // Tear down reachability listener
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOBReachabilityChangedNotification object:nil];
    [self.reachability stopNotifier];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    OBNetworkStatus newStatus = [self.reachability networkStatus];
    
    // Connection status just changed from not reachable to reachable
    // Let's send stored calls
    if (newStatus != OBNotReachable && self.previousNetworkStatus == OBNotReachable) {
        [OBReachability printNetworkStatus:newStatus];
        [self sendStoredCalls];
    }
    
    self.previousNetworkStatus = newStatus;
}

#pragma mark - Actions

- (void)addCall:(NSString *)path withParameters:(NSDictionary *)parameters {
    [self addCall:path withParameters:parameters completion:nil];
}

- (void)addCall:(NSString *)path withParameters:(NSDictionary *)parameters completion:(OBAddCallCompletion)completion {
    OBDebug(@"Adding '%@' call", path);
    
    // Create call object
    OBCall *call = [[OBCall alloc] init];
    call.path = path;
    call.parameters = parameters;
    call.timestamp = [[NSDate date] timeIntervalSince1970];
    if (self.userId) {
        call.userId = self.userId;
    } else {
        if (!self.tempUserId) {
            // Create temporary user ID
            self.tempUserId = [[NSUUID UUID] UUIDString];
            [self saveCache];
        }
        
        call.tempUserId = self.tempUserId;
    }
    
    // Check for network status
    OBNetworkStatus networkStatus = [self.reachability networkStatus];
    if (networkStatus != OBNotReachable) {
        // Network OK
        // Send the call right away
        [call sendCallWithCompletion:^(BOOL mustRetry) {
            if (completion != nil) {
                completion(!mustRetry);
            }

            // The call failed
            // Store it and retry wih exponential back off
            if (mustRetry) {
                [self saveCall:call];
                [self retryWithExponentialBackOff:@selector(sendStoredCalls)];
            }
        }];
    } else {
        // No network available
        // Store call to send later
        [self saveCall:call];
    }
}

- (void)setTempUserId:(NSString *)newTempUserId {
    if ([newTempUserId isEqualToString:@""]) {
        _tempUserId = nil;
    } else {
        _tempUserId = newTempUserId;
    }
    
    [self saveCache];
    return;
}

- (void)setUserId:(NSString *)newUserId {
    // Protect from invalid user IDs
    if ([newUserId isEqualToString:@""]) {
        _userId = nil;
        [self saveCache];
        return;
    }
    
    if (![newUserId isKindOfClass:[NSString class]]) {
        if ([newUserId isKindOfClass:[NSNumber class]]) {
            // If it's a number, we can convert it to a string
            newUserId = [NSString stringWithFormat:@"%@", newUserId];
        } else {
            // Otherwise just bail
            OBDebug(@"Error: User ID %@ is not a string", newUserId);
            return;
        }
    }
    
    OBDebug(@"Setting user ID %@", newUserId);
    
    // and sometimes it is [self name]
    if (self.tempUserId) {
        // We were using a temporary user ID until now
        // We need to identify previously stored calls
        for (OBCall *call in self.calls) {
            if (!call.userId) {
                call.userId = newUserId;
            }
        }
        
        // And link the temp user ID to the new user ID
        [self addCall:@"v2/identify" withParameters:@{@"user_id": newUserId, @"previous_id": self.tempUserId}];
        self.tempUserId = nil;
    }
    
    _userId = newUserId;
    [self saveCache];
}

- (void)setPushToken:(NSString *)pushToken {
    OBDebug(@"Setting push token %@", pushToken);
    _pushToken = pushToken;
    [self saveCache];
}

- (void)sendStoredCalls {
    
    if ([self.calls count] > 0) {
        NSArray *callsCopy = [NSArray arrayWithArray:self.calls];
        
        // Flush cache
        [self.calls removeAllObjects];
        [self saveCache];
        
        // Keep a counter of the number of calls we need to make
        // Because it is asynchronous and we need to kick off exponential back off after the last call is performed
        __block NSInteger remainingCalls = [callsCopy count];
        
        // Perform calls
        OBDebug(@"Sending %@ stored calls", @(remainingCalls));
        for (OBCall *call in callsCopy) {
            /*  - We run a loop over the contents of our array of calls, and performing the network request for each of them. The request is executed in a background thread, and when it is done, the block is executed.
                - The remainingCalls integer is decremented after a call is completed.
                - We want to trigger retryWithExponentialBackOff after the last call is completed,
                aka when remainingCalls reaches 0. That can be at the end of any call, not
                necessarily the last one we executed.
             */
            [call sendCallWithCompletion:^(BOOL mustRetry) {
                
                // Add the call again
                if (mustRetry) {
                    [self saveCall:call];
                }
                
                // Check if we're done with all the calls
                remainingCalls--;
                if (remainingCalls == 0) {
                    // If some calls failed, retry them after a delay
                    if ([self.calls count] > 0) {
                        [self retryWithExponentialBackOff:@selector(sendStoredCalls)];
                    }
                }
            }];
        }
    }
}

- (void)retryWithExponentialBackOff:(SEL)method {
    // make sure we don't have multiple timers
    [self.retryTimer invalidate];
    
    // Retry only 10 times
    if (self.retryDelay <= pow(2, 9)) {
        // Execute the method after the delay
        OBDebug(@"Retrying failed request in %@ seconds", @(self.retryDelay));
        self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:self.retryDelay target:self selector:method userInfo:nil repeats:NO];
        
        // Double the delay
        self.retryDelay = self.retryDelay * 2;
    } else {
        // Cancel the call and reinitialize the delay property
        self.retryDelay = 1;
    }
}

@end
