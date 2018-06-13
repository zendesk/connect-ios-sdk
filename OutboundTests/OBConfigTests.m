//
//  OBConfigTests.m
//  Outbound
//
//  Created by Emilien Huet on 1/22/16.
//  Copyright © 2016 Outbound.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBMainController.h"
#import "Outbound.h"
#import <OCMock/OCMock.h>

@interface OBConfigTests : XCTestCase

@end

@implementation OBConfigTests

- (void)testStartupConfig {
    [Outbound initWithPrivateKey:@"1234"];
    OBConfig *config = [[OBMainController sharedInstance] config];
    XCTAssertTrue(config.promptForPermission);
    XCTAssertEqualObjects(config.promptAtEvent, @"testEvent");
    XCTAssertFalse(config.promptAtInstall);
    XCTAssertFalse(config.remoteKill);
    XCTAssertNotNil(config.fetchDate);
}

- (void)testRemoteKill {
    // stubbed data will return enabled:false
    [Outbound initWithPrivateKey:@"disabled"];
    OBConfig *config = [[OBMainController sharedInstance] config];
    XCTAssertTrue(config.remoteKill);
    
    // test that tracking an event doesn't add a call
    NSInteger callsBefore = [[[[OBMainController sharedInstance] callsCache] calls] count];
    [Outbound trackEvent:@"test" withProperties:nil];
    XCTAssertEqual([[[[OBMainController sharedInstance] callsCache] calls] count], callsBefore);
}

/**
 * SDK operations are halted until the config has been fetched. 
 * In this test we check that nothing is executed until that's the case by making the config call respond after 5 seconds, 
 * and then we check that everything is executed after.
 *
 * This test will fail if run with all the others because they reset application state.
 */
- (void)testWaitForConfig {
    // fake network call will return after 5 seconds
    [Outbound initWithPrivateKey:@"wait"];
    
    // test that tracking an event doesn't add a call
    [Outbound trackEvent:@"test" withProperties:nil];
    XCTAssertEqual([[[[OBMainController sharedInstance] callsCache] calls] count], 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Calls executed after config fetched"];
    
    // test that previous tracking event adds a call after config is fetched
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        XCTAssertEqual([[[[OBMainController sharedInstance] callsCache] calls] count], 1);
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:7.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
}

@end
