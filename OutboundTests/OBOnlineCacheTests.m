/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OBCallsCache.h"
#import "OBCall.h"
#import "Outbound.h"
#import "OBMainController.h"
#import "OBNetwork.h"
#import "OBConfig.h"

@interface OBOnlineCacheTests : XCTestCase

@end

@implementation OBOnlineCacheTests

- (void)setUp {
    [super setUp];

    // Destroy existing cache file for the device
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cacheLocation = [documentsPath stringByAppendingPathComponent:@"outbound.dat"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheLocation]) {
        [[NSFileManager defaultManager] removeItemAtPath:cacheLocation error:nil];
    }
    
    // Mock reachability, make it return rechable
    id reachabilityMock = OCMClassMock([OBReachability class]);
    OCMStub([reachabilityMock networkStatus]).andReturn(OBReachableViaWiFi);
    
    // Mock network, make it return 500s
    id mockClient = [OCMockObject mockForClass:[OBNetwork class]];
    [[[mockClient expect] andDo:^(NSInvocation *invocation) {
        void (^completion)(id json, NSInteger statusCode, NSError *error) = nil;
        [invocation getArgument:&completion atIndex:5];
        completion(nil, 500, [NSError errorWithDomain:@"mock" code:500 userInfo:@{}]);
    }] postPath:[OCMArg any] withAPIKey:[OCMArg any] parameters:[OCMArg any] andCompletion:[OCMArg any]];
    
    // Start SDK
    [Outbound setDebug:YES];
    [Outbound initWithPrivateKey:@"1234"];
    [[OBMainController sharedInstance] callsCache].reachability = reachabilityMock;
}

- (void)tearDown {
    [super tearDown];
}


/**
 Verify that failed network requests launch a timer to try the request again
 */
- (void)testRetryTimer {
    // Mock NSTimer class
    id mockTimer = OCMClassMock([NSTimer class]);
    [[[mockTimer expect] ignoringNonObjectArgs] scheduledTimerWithTimeInterval:0
                                                target:[OCMArg any]
                                              selector:[OCMArg anySelector]
                                              userInfo:[OCMArg any]
                                               repeats:NO];
    
    // Add 1 call to cache
    [Outbound trackEvent:@"event" withProperties:@{@"foo": @"bar"}];
    
    // Verify that mock method was called
    [mockTimer verify];
}


@end
