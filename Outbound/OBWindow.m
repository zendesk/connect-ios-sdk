//
//  BSWindow.m
//  BabelStrings
//
//  Created by Emilien on 2014-06-13.
//  Copyright (c) 2014 Babel Strings. All rights reserved.
//

#import "OBWindow.h"

#define OBDegreesToRadians(degrees) (degrees * M_PI / 180)
#define OBIsIOS8    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface OBWindow ()

- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation OBWindow

- (id)init {
    self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if (self) {
        [self setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        if (!OBIsIOS8) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    if (!OBIsIOS8) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Orientation and frame

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
    
    switch (orientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
            [self setTransform:CGAffineTransformMakeRotation(-OBDegreesToRadians(90))];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self setTransform:CGAffineTransformMakeRotation(OBDegreesToRadians(90))];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setTransform:CGAffineTransformMakeRotation(OBDegreesToRadians(180))];
            break;
        case UIInterfaceOrientationPortrait:
        default:
            [self setTransform:CGAffineTransformMakeRotation(OBDegreesToRadians(0))];
            break;
    }
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        self.frame = CGRectMake(0.0, 0.0, screenSize.width + 20.0, screenSize.height);
    }
    else
    {
        self.frame = CGRectMake(0.0, 0.0, screenSize.width, screenSize.height + 20.0);
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    [self setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

@end
