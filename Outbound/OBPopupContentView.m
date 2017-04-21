//
//  BSPopupContentView.m
//  Colatris
//
//  Created by Emilien on 2014-10-13.
//  Copyright (c) 2014 Parlance. All rights reserved.
//

#import "OBPopupContentView.h"
#import "OBPopupWindow.h"

@interface OBPopupContentView ()

- (void)keyboardDidAppear:(NSNotification *)notif;
- (void)keyboardDidDisappear:(NSNotification *)notif;

@end

@implementation OBPopupContentView

- (id)initWithRootViewController:(UIViewController *)vc
{
    OBPopupWindow *window = [OBPopupWindow sharedPopup];
    if ((self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth(window.bounds), CGRectGetHeight(window.bounds))]))
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.clipsToBounds = YES;
        self.tintColor = [[[UIApplication sharedApplication] keyWindow] tintColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardWillHideNotification object:nil];
        
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
        self.navigationController.view.frame = self.bounds;
        self.navigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.navigationController.view];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keyboard handling

- (void)keyboardDidAppear:(NSNotification *)notif
{
    [UIView animateWithDuration:.3 animations:^{
        NSValue *keyboardFrameValue = notif.userInfo[UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
        CGFloat keyboardHeight = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? keyboardFrame.size.height : keyboardFrame.size.width;
        
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.superview.bounds) - keyboardHeight;
        self.frame = frame;
    }];
}

- (void)keyboardDidDisappear:(NSNotification *)notif
{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = self.frame;
        frame.size.height = CGRectGetHeight(self.superview.bounds);
        self.frame = frame;
    }];
}

#pragma mark - Actions

- (void)presentPopupAnimated:(BOOL)animated
{
    // Get singleton popup window
    OBPopupWindow *window = [OBPopupWindow sharedPopup];
    [window addSubview:self];
    
    // Animate in
    if (animated) {
        self.transform = CGAffineTransformMakeScale(.1, .1);
        self.alpha = 0.0;
        window.darkMask.alpha = 0.0;
        
        [window makeKeyAndVisible];
        window.hidden = NO;
        
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1.0;
            window.darkMask.alpha = 1.0;
        } completion:nil];
    } else {
        [window makeKeyAndVisible];
        window.hidden = NO;
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    OBPopupWindow *window = [OBPopupWindow sharedPopup];
    
    if (animated)
    {
        [UIView animateWithDuration:.3 animations:^{
            self.transform = CGAffineTransformMakeScale(.1, .1);
            self.alpha = 0.0;
            window.darkMask.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [window resignKeyWindow];
            [window setHidden:YES];
            window.darkMask.alpha = 1;
        }];
    }
    else
    {
        [self removeFromSuperview];
        [window resignKeyWindow];
        [window setHidden:YES];
    }
}

- (void)cancel:(UIButton *)sender
{
    [self dismissAnimated:YES];
}

@end
