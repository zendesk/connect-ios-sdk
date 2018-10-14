/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */


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
