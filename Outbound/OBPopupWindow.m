/*
 *  Copyright (c) 2018 Zendesk. All rights reserved.
 *
 *  By downloading or using the Zendesk Mobile SDK, You agree to the Zendesk Master
 *  Subscription Agreement https://www.zendesk.com/company/customers-partners/master-subscription-agreement and Application Developer and API License
 *  Agreement https://www.zendesk.com/company/customers-partners/application-developer-api-license-agreement and
 *  acknowledge that such terms govern Your use of and access to the Mobile SDK.
 *
 */

#import "OBPopupWindow.h"

@interface OBPopupWindow ()

@end

@implementation OBPopupWindow

+ (OBPopupWindow *)sharedPopup
{
    OBSingleton(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.windowLevel = UIWindowLevelNormal + 2;
        
        self.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        
        self.darkMask = [[UIView alloc] initWithFrame:self.bounds];
        self.darkMask.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.darkMask.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.3];
        [self addSubview:self.darkMask];
    }
    return self;
}

@end
