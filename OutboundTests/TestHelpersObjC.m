//
//  TestHelpersObjC.m
//  OutboundTests
//
//  Created by Alan Egan on 28/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

#import "TestHelpersObjC.h"
#import <OCMock/OCMock.h>
#import "OBCallsCache.h"
#import "OBMainController.h"

@implementation TestHelpersObjC

+ (void)mockNetworkStatus:(OBNetworkStatus)status {
    // Mock reachability, make it return OBNotReachable
    id reachabilityMock = OCMClassMock([OBReachability class]);
    OCMStub([reachabilityMock networkStatus]).andReturn(OBNotReachable);
    [[OBMainController sharedInstance] callsCache].reachability = reachabilityMock;
}

@end
