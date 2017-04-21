//
//  BSPopupRootViewController.m
//  Colatris
//
//  Created by Emilien on 2014-11-07.
//  Copyright (c) 2014 Parlance. All rights reserved.
//

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
