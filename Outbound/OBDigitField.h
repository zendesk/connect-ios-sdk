//
//  OBDigitField.h
//  Outbound
//
//  Created by Emilien on 2015-06-18.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBDigitField;

@protocol OBDigitFieldDelegate

- (void)textFieldDidDelete:(OBDigitField *)field;

@end

@interface OBDigitField : UITextField

@property (nonatomic) NSObject <OBDigitFieldDelegate> *obDelegate;

@end
