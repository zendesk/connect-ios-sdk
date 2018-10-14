/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "NSURLSession+OBJSON.h"

@implementation NSURLSession (OBJSON)

- (NSURLSessionDataTask *)ob_jsonDataTaskForRequest:(NSURLRequest *)request completion:(void (^)(id json, NSURLResponse *response, NSError *error))completion {
    NSParameterAssert(request != nil);
    NSParameterAssert(completion != nil);

    return [self dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        id json = nil;
        NSError *error = requestError;

        if (data.length > 0 && requestError == nil) {
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(json, response, error);
        });
    }];
}

@end
