//
//  TestHelpersObjC.h
//  OutboundTests
//
//  Created by Alan Egan on 28/05/2018.
//  Copyright © 2018 Outbound.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBReachability.h"

@interface TestHelpersObjC : NSObject

+ (void)mockNetworkStatus:(OBNetworkStatus)status;

@end
