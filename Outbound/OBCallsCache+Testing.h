//
//  OBCallsCache+Testing.h
//  Outbound
//
//  Created by Alan Egan on 30/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//


#import "OBCallsCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBCallsCache (Testing)

/**
 Used to set the number of exponential retries to a sensible number for testing.

 @param count The number of times to to retry.
 */
+ (void)setMaxRetryAttempts:(NSUInteger)count;

@end

NS_ASSUME_NONNULL_END
