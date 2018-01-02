//
//  NSURLSession+NSURLSession_OBJSON.h
//  Outbound
//
//  Created by Josh Kugelmann on 3/1/18.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (OBJSON)

- (NSURLSessionDataTask *)ob_jsonDataTaskForRequest:(NSURLRequest *)request completion:(void (^)(id _Nullable json, NSURLResponse * _Nullable response, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
