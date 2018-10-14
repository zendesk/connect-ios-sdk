/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

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
