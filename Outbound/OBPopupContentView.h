//
//  BSPopupContentView.h
//  Colatris
//
//  Created by Emilien on 2014-10-13.
//  Copyright (c) 2014 Parlance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBPopupContentView : UIView

@property (nonatomic) UINavigationController *navigationController;

- (id)initWithRootViewController:(UIViewController *)vc;
- (void)presentPopupAnimated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;
- (void)cancel:(id)sender;

@end
