//
//  OBCallsCacheTests.m
//  Outbound
//
//  Created by Emilien on 2015-04-22.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OBCallsCache.h"
#import "OBCall.h"
#import "Outbound.h"
#import "OBMainController.h"

@interface OBOfflineCacheTests : XCTestCase

@end

@implementation OBOfflineCacheTests

- (void)setUp {
    [super setUp];
    
    // Mock reachability, make it return OBNotReachable
    id reachabilityMock = OCMClassMock([OBReachability class]);
    OCMStub([reachabilityMock networkStatus]).andReturn(OBNotReachable);
    
    // Start SDK
    [Outbound setDebug:YES];    
    [Outbound initWithPrivateKey:@"1234"];
    [[OBMainController sharedInstance] callsCache].reachability = reachabilityMock;
}

- (void)tearDown {
    [super tearDown];
}

/**
 Test that calls are stored when network is down
 */
- (void)testCallCaching {
    // Add 2 calls to cache
    [Outbound identifyUserWithId:@"42" attributes:@{@"first_name": @"John", @"last_name": @"Smith", @"email": @"john@company.com"}];
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];
    
    // The cache should contain 2 calls
    XCTAssertEqual([[[OBMainController sharedInstance] callsCache].calls count], 2);
}

/**
 Test cache integrity after serialization and deserialization.
 */
- (void)testSerialization {
    
    // Mock cache contents
    [Outbound identifyUserWithId:@"42" attributes:@{@"first_name": @"John", @"last_name": @"Smith", @"email": @"john@company.com"}];
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];
    
    // Archive cache to a temp file
    NSString *tempPath = @"/tmp/obcache.dat";
    OBCallsCache *cache = [[OBMainController sharedInstance] callsCache];
    [NSKeyedArchiver archiveRootObject:cache toFile:tempPath];
    
    // Unarchive cache
    OBCallsCache *cacheClone = [NSKeyedUnarchiver unarchiveObjectWithFile:tempPath];
    
    // Check unarchived object properties
    XCTAssertEqualObjects(cacheClone.userId, cache.userId);
    XCTAssertEqual([cacheClone.calls count], 2);
}

/**
 Check that stored anonymous calls are identified after an identify call
 
 Corresponding spec:
    When any call other than `identify` is called:
        If identify has not been called, generate an anonymous ID(guaranteed unique, GUID, maybe?) for the user.
        Cache the anonymous ID and use it in the track/disable/register call. Make sure the specify in cache that it is an anonymous ID.
 */
- (void)testIdentify {
    
    // Make an anonymous call to event
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];
    
    // Verify that the call has no user ID and a temp user ID
    OBCall *call = [[[OBMainController sharedInstance] callsCache] calls][0];
    XCTAssertNotNil(call);
    XCTAssertEqualObjects(call.path, @"v2/track");
    XCTAssertNil(call.userId);
    XCTAssertNotNil(call.tempUserId);
    
    // Identify a user
    [Outbound identifyUserWithId:@"42" attributes:@{@"first_name": @"John", @"last_name": @"Smith", @"email": @"john@company.com"}];
    
    // Verify that the first call now has the right user ID
    XCTAssertNotNil(call.userId);
    XCTAssertEqualObjects(call.userId, @"42");
}

/**
 Verify logic:
 
    If there already exists a user in cache
        If cached user is different from new user
            If cached user is anonymous user
                Make alias API call to Outbound
            else
                Make [disable device token API call](https://github.com/outboundio/api#disable-request) to Outbound for the cached user.
            EndIf

            Clear old cache from local storage if previous user is cached
        EndIf
    EndIf
 
    Cache the user to local storage.
 */
- (void)testLogOut {
    
    // Identify a user
    [Outbound identifyUserWithId:@"42" attributes:@{@"first_name": @"John", @"last_name": @"Smith", @"email": @"john@company.com"}];
    
    // Track an event
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];

    // Verify that the track call has user ID
    OBCall *call = [[[OBMainController sharedInstance] callsCache] calls][1];
    XCTAssertNotNil(call);
    XCTAssertEqualObjects(call.userId, @"42");
    
    // Register a push token for this user
    [Outbound registerDeviceToken:[@"token" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Identify another user
    [Outbound identifyUserWithId:@"24" attributes:@{@"first_name": @"Rick", @"last_name": @"Smith", @"email": @"rick@company.com"}];
    
    // Check that a call to unregister push token was added
    XCTAssertEqual([[[[OBMainController sharedInstance] callsCache] calls] count], 6);
    OBCall *unregisterCall = [[[OBMainController sharedInstance] callsCache] calls][4];
    XCTAssertEqualObjects(unregisterCall.path, @"v2/apns/disable");
    XCTAssertEqualObjects(unregisterCall.parameters[@"user_id"], @"42");

    // Make another call to event
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];
    
    // Verify that the first track call still has first user ID
    XCTAssertEqualObjects(call.userId, @"42");
    
    // Verify that second track call has second user ID
    XCTAssertEqual([[[[OBMainController sharedInstance] callsCache] calls] count], 7);
    OBCall *call2 = [[[OBMainController sharedInstance] callsCache] calls][6];
    XCTAssertNotNil(call2);
    XCTAssertEqualObjects(call2.userId, @"24");
    
    // Verify cached global user ID is second user
    XCTAssertEqualObjects([[[OBMainController sharedInstance] callsCache] userId], @"24");
}

@end
