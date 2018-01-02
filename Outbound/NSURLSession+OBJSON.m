//
//  NSURLSession+NSURLSession_OBJSON.m
//  Outbound
//
//  Created by Josh Kugelmann on 3/1/18.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

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

static void OBDebugRequest(NSURLRequest *request, NSInteger statusCode, NSError *error, id json) {
}
