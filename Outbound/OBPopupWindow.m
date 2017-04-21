//
//  BSPopupWindow.m
//  BabelStrings
//
//  Created by Emilien on 2014-05-07.
//  Copyright (c) 2014 Babel Strings. All rights reserved.
//

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
