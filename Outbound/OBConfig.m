//
//  OBConfig.m
//  Outbound
//
//  Created by Dhruv on 2015-06-19.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBConfig.h"
#import "OBNetwork.h"

#define kHasBeenPrompted @"hasBeenPrompted"
#define kGavePermission  @"gavePermission"
#define kPushToken       @"pushToken"
#define kFetchDate       @"fetchDate"
#define kPromptEvent     @"promptEvent"
#define kPrePrompt       @"prePrompt"
#define kPrompt          @"prompt"
#define kPromptInstall   @"promptInstall"
#define kRemoteKill      @"remoteKill"

@implementation OBConfig

- (void)completeWithData:(NSDictionary *)rawConfig {
    if (rawConfig) {
        NSDictionary* accountSettings = [rawConfig objectForKey:@"account"];
        if([accountSettings objectForKey:@"prompt"]) {
            self.promptForPermission = [accountSettings[@"prompt"] boolValue];
        }
        
        if (self.promptForPermission) {
            NSString *event = (NSString*)[accountSettings objectForKey:@"prompt_event"];
            if (event && ![event isEqualToString:@""]) {
                self.promptAtEvent = event;
            } else {
                self.promptAtInstall = YES;
            }
        }
        
        if([accountSettings objectForKey:@"pre_prompt"]) {
            self.prePrompt = (NSDictionary*) accountSettings[@"pre_prompt"];
        }
        
        if ([rawConfig objectForKey:@"enabled"]) {
            self.remoteKill = ![rawConfig[@"enabled"] boolValue];
        }
    }
}

- (void)encodeWithCoder: (NSCoder*) encoder {
    [encoder encodeBool:self.hasBeenPrompted forKey:kHasBeenPrompted];
    [encoder encodeBool:self.gavePermission forKey:kGavePermission];
    [encoder encodeBool:self.remoteKill forKey:kRemoteKill];
    [encoder encodeObject:self.pushToken forKey:kPushToken];
    [encoder encodeObject:self.fetchDate forKey:kFetchDate];
    [encoder encodeObject:self.promptAtEvent forKey:kPromptEvent];
    [encoder encodeObject:self.prePrompt forKey:kPrePrompt];
    [encoder encodeBool:self.promptForPermission forKey:kPrompt];
    [encoder encodeBool:self.promptAtInstall forKey:kPromptInstall];
}

- (id)initWithCoder: (NSCoder*) decoder {
    self = [super init];
    if (self) {
        self.hasBeenPrompted = [decoder decodeBoolForKey:kHasBeenPrompted];
        self.gavePermission = [decoder decodeBoolForKey:kGavePermission];
        self.remoteKill = [decoder decodeBoolForKey:kRemoteKill];
        self.pushToken = [decoder decodeObjectForKey:kPushToken];
        self.fetchDate = [decoder decodeObjectForKey:kFetchDate];
        self.promptAtEvent = [decoder decodeObjectForKey:kPromptEvent];
        self.prePrompt = [decoder decodeObjectForKey:kPrePrompt];
        self.promptForPermission = [decoder decodeBoolForKey:kPrompt];
        self.promptAtInstall = [decoder decodeBoolForKey:kPromptInstall];
    }
    return self;
}

- (void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[OBConfig configFilePath]];
}

+ (void)getSdkConfigWithCompletion:(void (^)(OBConfig *config))completion {
    OBConfig *config = nil;
    if ([OBConfig configFilePath] && [[NSFileManager defaultManager] fileExistsAtPath:[OBConfig configFilePath]]) {
        config = [NSKeyedUnarchiver unarchiveObjectWithFile:[OBConfig configFilePath]];
    } else {
        config = [[OBConfig alloc] init];
    }
    
    // Don't fetch config if it was fetched less than an hour ago
    if (config.fetchDate && [config.fetchDate compare:[NSDate dateWithTimeIntervalSinceNow:-600]] == NSOrderedDescending) {
        completion(config);
    } else {
        [OBNetwork getPath:[NSString stringWithFormat:@"i/config/sdk/%@/%@", OBClientName, OBClientVersion] withAPIKey:[[OBMainController sharedInstance] apiKey] andCompletion:^(NSInteger statusCode, NSError *error, NSObject *response) {
            if (!error && response) {
                [config completeWithData:(NSDictionary *)response];
                config.fetchDate = [NSDate date];
                [config save];
            }
            
            completion(config);
        }];
    }
}

- (void)setHasBeenPrompted:(bool)hasBeenPrompted {
    _hasBeenPrompted = hasBeenPrompted;
    [self save];
}

- (void)setGavePermission:(bool)gavePermission {
    _hasBeenPrompted = true;
    _gavePermission = gavePermission;
    [self save];
}

- (void)setPushToken:(NSString *)pushToken {
    _hasBeenPrompted = true;
    _gavePermission = true;
    _pushToken = pushToken;
    [self save];
}

+ (NSString *)configFilePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:@"outbound.config"];
}

@end
