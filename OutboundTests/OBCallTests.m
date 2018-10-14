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
#import "OBCall.h"
#import "OBNetwork.h"

@interface OBCallTests : XCTestCase

@property (nonatomic) OBCall *call;

@end

@implementation OBCallTests

- (void)setUp {
    [super setUp];
    
    self.call = [[OBCall alloc] init];
    self.call.userId = @"42";
    self.call.path = @"identify";
    self.call.parameters = @{@"first_name": @"John", @"last_name": @"Smith", @"email": @"john@company.com"};
}

- (void)tearDown {
    [super tearDown];
}

/**
 Test call integrity after serialization and deserialization
 */
- (void)testSerialization {
    NSString *tempPath = @"/tmp/obcall.dat";
    
    // Archive call to a temp file
    [NSKeyedArchiver archiveRootObject:self.call toFile:tempPath];
    
    // Unarchive call
    OBCall *callClone = [NSKeyedUnarchiver unarchiveObjectWithFile:tempPath];
    
    // Check unarchived object properties
    XCTAssertEqualObjects(callClone.userId, self.call.userId);
    XCTAssertEqualObjects(callClone.path, self.call.path);
    XCTAssertEqualObjects(callClone.parameters, self.call.parameters);
}

@end
