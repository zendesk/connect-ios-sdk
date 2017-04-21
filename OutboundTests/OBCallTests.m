//
//  OBCallTests.m
//  Outbound
//
//  Created by Emilien on 2015-04-23.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

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
