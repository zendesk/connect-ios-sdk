//
//  OBConfig+UnitTests.m
//  Outbound
//
//  Created by Emilien Huet on 1/22/16.
//  Copyright © 2016 Outbound.io. All rights reserved.
//

#import "OBConfig+UnitTests.h"

@implementation OBConfig (UnitTests)

//+ (void)getSdkConfigWithCompletion:(void (^)(OBConfig *config))completion {
//    OBConfig *mockConfig = [[OBConfig alloc] init];
//    mockConfig.hasBeenPrompted = YES;
//    mockConfig.gavePermission = YES;
//    mockConfig.remoteKill = NO;
//    mockConfig.pushToken = @"token";
//    mockConfig.fetchDate = [NSDate date];
//    mockConfig.promptAtEvent = nil;
//    mockConfig.prePrompt = nil;
//    mockConfig.promptForPermission = NO;
//    mockConfig.promptAtInstall = NO;
//    
//    completion(mockConfig);
//}

+ (NSString *)configFilePath {
    return nil;
}

@end
