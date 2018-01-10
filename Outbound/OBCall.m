//
//  OBCall.m
//  Outbound
//
//  Created by Emilien on 2015-04-20.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBCall.h"
#import "OBNetwork.h"

// Serialization keys
#define OBCallUser          @"user"
#define OBCallTempUser      @"tempUser"
#define OBCallParameters    @"parameters"
#define OBCallPath          @"path"
#define OBCallTimestamp     @"timestamp"

@interface OBCall () 

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

@implementation OBCall

#pragma mark - Serialization

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        // TODO(Dhruv): Why do these start with _ rather than being properties on `self`?
        _userId = [coder decodeObjectForKey:OBCallUser];
        _tempUserId = [coder decodeObjectForKey:OBCallTempUser];
        _parameters = [coder decodeObjectForKey:OBCallParameters];
        _path = [coder decodeObjectForKey:OBCallPath];
        _timestamp = [coder decodeDoubleForKey:OBCallTimestamp];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:OBCallUser];
    [coder encodeObject:self.tempUserId forKey:OBCallTempUser];
    [coder encodeObject:self.parameters forKey:OBCallParameters];
    [coder encodeObject:self.path forKey:OBCallPath];
    [coder encodeDouble:self.timestamp forKey:OBCallTimestamp];
}

#pragma mark - Network request

- (void)sendCallWithCompletion:(void (^)(BOOL mustRetry))completion {
    
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:self.parameters];
    
    NSString* apiKey = [[OBMainController sharedInstance] apiKey];
    if (!apiKey) {
        OBDebug(@"Cannot make %@ call before setting api key.", self.path);
        return;
    }
    
    // Add the user ID or temp user ID to the call parameters
    // TODO(Dhruv): Does `OBCall` really need to differentiate between userId and tempUserId?
    if (!self.parameters[@"user_id"]) {
        if (self.userId) {
            mutableParams[@"user_id"] = self.userId;
        } else if (self.tempUserId) {
            mutableParams[@"anon_id"] = self.tempUserId;
        } else {
            // Don't make calls where we do not know the user Id.
            OBDebug(@"Will not perform network call because user_id is not set for: %@", self.path);
            return;
        }
    }
    
    // Add timestamp to call
    // TODO(Dhruv): This seems problematic. You want the timestamp to be set to when the client tried to make the call
    // and not when the call got made successfully.
    mutableParams[@"timestamp"] = @(floor(self.timestamp));
    
    OBDebug(@"Performing network call '%@'", self.path);
    
    // Perform the network request
    [OBNetwork postPath:self.path
             withAPIKey:[[OBMainController sharedInstance] apiKey]
             parameters:mutableParams
          andCompletion:^(id json, NSInteger statusCode, NSError *error) {
              
              // Check for response status code and set mustRetry parameter accordingly
              completion(statusCode == 0 || statusCode >= 500);
              
          }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<OBCall %@ %@ %@>", self.path, self.parameters, @(self.timestamp)];
}

@end
