//
//  OBDigitField.m
//  Outbound
//
//  Created by Emilien on 2015-06-18.
//  Copyright (c) 2015 Outbound.io. All rights reserved.
//

#import "OBDigitField.h"

@implementation OBDigitField

- (void)deleteBackward {
    [super deleteBackward];

    if (self.obDelegate) {
        [self.obDelegate textFieldDidDelete:self];
    }
}

@end
