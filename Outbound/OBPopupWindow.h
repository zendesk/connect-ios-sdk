//
//  BSPopupWindow.h
//  BabelStrings
//
//  Created by Emilien on 2014-05-07.
//  Copyright (c) 2014 Babel Strings. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBWindow.h"

@interface OBPopupWindow : OBWindow

+ (OBPopupWindow *)sharedPopup;

@property (nonatomic) UIView *darkMask;

@end
