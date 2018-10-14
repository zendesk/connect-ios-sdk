/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "OBPopupRootViewController.h"

@interface OBPopupRootViewController ()

@end

@implementation OBPopupRootViewController

- (id)init {
    if ((self = [super init])) {
        self.popup = [[OBPopupContentView alloc] initWithRootViewController:self];
    }
    return self;
}

@end
