/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "OBConfig.h"
#import "OBNetwork.h"

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
        _remoteKill = [decoder decodeBoolForKey:kRemoteKill];
        _fetchDate = [decoder decodeObjectForKey:kFetchDate];
        _promptAtEvent = [decoder decodeObjectForKey:kPromptEvent];
        _prePrompt = [decoder decodeObjectForKey:kPrePrompt];
        _pushToken = [decoder decodeObjectForKey:kPushToken];
        _promptForPermission = [decoder decodeBoolForKey:kPrompt];
        _promptAtInstall = [decoder decodeBoolForKey:kPromptInstall];
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
        [OBNetwork getPath:[NSString stringWithFormat:@"i/config/sdk/%@/%@", OBClientName, OBClientVersion] withAPIKey:[[OBMainController sharedInstance] apiKey] andCompletion:^(id json, NSInteger statusCode, NSError *error) {
            if (!error && json) {
                [config completeWithData:(NSDictionary *)json];
                config.fetchDate = [NSDate date];
                [config save];
            }
            
            completion(config);
        }];
    }
}

+ (NSString *)configFilePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:@"outbound.config"];
}

- (void)setPushToken:(NSString *)pushToken {
    _pushToken = pushToken;
    [self save];
}

@end
