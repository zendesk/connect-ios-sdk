//
//  OBAdminViewController.m
//  Outbound
//
//  Created by Emilien on 2015-04-26.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBAdminViewController.h"
#import "OBDigitField.h"
#import "OBNetwork.h"
#import "OBMainController.h"

#define OBCorrectCode @"3279"

@interface OBAdminViewController () <UITextFieldDelegate, OBDigitFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UIView *container;
@property (nonatomic) UILabel *subtitleLabel;
@property (nonatomic) OBDigitField *digit1;
@property (nonatomic) OBDigitField *digit2;
@property (nonatomic) OBDigitField *digit3;
@property (nonatomic) OBDigitField *digit4;

- (void)validate;

@end

@implementation OBAdminViewController

- (void)loadView {
    [super loadView];
    
    self.navigationController.navigationBarHidden = YES;
    
    // Gesture recognizer to close popup if tapped around
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.popup action:@selector(dismissAnimated:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    // Container
    self.container = [[UIView alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width - 40, 250)];
    self.container.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    self.container.layer.cornerRadius = 10;
    self.container.layer.masksToBounds = YES;
    self.container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.container];
    
    // Title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.container.bounds.size.width - 20, 80)];
    titleLabel.text = @"Admin device pairing";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    titleLabel.numberOfLines = 0;
    [self.container addSubview:titleLabel];
    
    // Subtitle label
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, self.container.bounds.size.width - 20, 20)];
    self.subtitleLabel.text = @"Enter the 4-digit code";
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.font = [UIFont fontWithName:@"Avenir-Light" size:15];
    self.subtitleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.container addSubview:self.subtitleLabel];
    
    // Background blur
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.container insertSubview:toolbar atIndex:0];
    
    // Text fields
    UIView *digitsContainer = [[UIView alloc] initWithFrame:CGRectMake(20, 140, self.container.bounds.size.width - 40, 80)];
    digitsContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.container addSubview:digitsContainer];
    
    self.digit1 = [[OBDigitField alloc] init];
    self.digit2 = [[OBDigitField alloc] init];
    self.digit3 = [[OBDigitField alloc] init];
    self.digit4 = [[OBDigitField alloc] init];
    NSDictionary *viewsDict = @{@"d1": self.digit1, @"d2": self.digit2, @"d3": self.digit3, @"d4": self.digit4};
    
    for (OBDigitField *tf in [viewsDict allValues]) {
        tf.delegate = self;
        tf.obDelegate = self;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.keyboardAppearance = UIKeyboardAppearanceAlert;
        tf.translatesAutoresizingMaskIntoConstraints = NO;
        tf.font = [UIFont fontWithName:@"Avenir-Book" size:50];
        tf.textAlignment = NSTextAlignmentCenter;
        tf.borderStyle = UITextBorderStyleRoundedRect;
        tf.backgroundColor = [UIColor whiteColor];
        [digitsContainer addSubview:tf];
        
        // Vertical layout
        [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tf]|" options:0 metrics:nil views:@{@"tf": tf}]];
    }
    
    // Horizontal layout
    [self.container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[d1]-20-[d2(==d1)]-20-[d3(==d1)]-20-[d4(==d1)]|" options:0 metrics:nil views:viewsDict]];
}

/**
 Place cursor in first text field when panel opens
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.digit1 becomeFirstResponder];
}

/**
 Jump to the next text field after a number is entered, and validate after the last one.
 If delete key was pressed, jump to previous text field.
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.digit1) {
        if ([string length] > 0) {
            self.digit1.text = string;
            [self.digit2 becomeFirstResponder];
        } else {
            self.digit1.text = nil;
        }
    } else if (textField == self.digit2) {
        if ([string length] > 0) {
            self.digit2.text = string;
            [self.digit3 becomeFirstResponder];
        } else {
            self.digit2.text = nil;
            [self.digit1 becomeFirstResponder];
        }
    } else if (textField == self.digit3) {
        if ([string length] > 0) {
            self.digit3.text = string;
            [self.digit4 becomeFirstResponder];
        } else {
            self.digit3.text = nil;
            [self.digit2 becomeFirstResponder];
        }
    } else {
        if ([string length] > 0) {
            self.digit4.text = string;
            [self validate];
        } else {
            self.digit4.text = nil;
            [self.digit3 becomeFirstResponder];
        }
    }
    return NO;
}

/**
 If delete key pressed, jump to previous text field even when text is empty
 */
- (void)textFieldDidDelete:(OBDigitField *)textField {
    if (textField == self.digit1) {
        self.digit1.text = nil;
    } else if (textField == self.digit2) {
        self.digit1.text = nil;
        [self.digit1 becomeFirstResponder];
    } else if (textField == self.digit3) {
        self.digit2.text = nil;
        [self.digit2 becomeFirstResponder];
    } else {
        self.digit3.text = nil;
        [self.digit3 becomeFirstResponder];
    }
}

/**
 Validate code
 */
- (void)validate {
    int code = [[NSString stringWithFormat:@"%@%@%@%@", self.digit1.text, self.digit2.text, self.digit3.text, self.digit4.text] intValue];
    NSString *apikey = [[OBMainController sharedInstance] apiKey];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:code], @"code",
                                   [[[OBMainController sharedInstance] config] pushToken], @"deviceToken",
                                   [[UIDevice currentDevice] name], @"deviceName", nil];
    [OBNetwork postPath:@"i/testsend/push/pair/ios" withAPIKey:apikey parameters:params andCompletion:^(NSInteger statusCode, NSError *error, NSObject *response) {
        if (statusCode == 200) {
            OBDebug(@"[OB] Correct code %d", code);
            self.subtitleLabel.text = @"Success!";
            self.subtitleLabel.textColor = [UIColor greenColor];
            [self.popup performSelector: @selector(dismissAnimated:) withObject:self.popup afterDelay:1];
        } else {
            OBDebug(@"[OB] Wrong code %d", code);
            self.subtitleLabel.text = @"Pairing failed";
            self.subtitleLabel.textColor = [UIColor redColor];
            
            // Spring animation for incorrect code
            [UIView animateKeyframesWithDuration:.6 delay:0 options:0 animations:^{
                CGRect originalFrame = self.container.frame;
                
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.1 animations:^{
                    CGRect f = originalFrame;
                    f.origin.x += 40;
                    self.container.frame = f;
                }];
                
                [UIView addKeyframeWithRelativeStartTime:.1 relativeDuration:.2 animations:^{
                    CGRect f = originalFrame;
                    f.origin.x -= 40;
                    self.container.frame = f;
                }];
                
                [UIView addKeyframeWithRelativeStartTime:.3 relativeDuration:.2 animations:^{
                    CGRect f = originalFrame;
                    f.origin.x += 20;
                    self.container.frame = f;
                }];
                
                [UIView addKeyframeWithRelativeStartTime:.5 relativeDuration:.3 animations:^{
                    CGRect f = originalFrame;
                    f.origin.x -= 20;
                    self.container.frame = f;
                }];
                
                [UIView addKeyframeWithRelativeStartTime:.8 relativeDuration:.2 animations:^{
                    self.container.frame = originalFrame;
                }];
            } completion:^(BOOL finished) {
                // Clear input and go back to first digit field
                self.digit1.text = nil;
                self.digit2.text = nil;
                self.digit3.text = nil;
                self.digit4.text = nil;
                [self.digit1 becomeFirstResponder];
            }];
        }
    }];
}

// Only trigger close gesture if touch is outside popup
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return !CGRectContainsPoint(self.container.frame, [touch locationInView:self.view]);
}

@end
