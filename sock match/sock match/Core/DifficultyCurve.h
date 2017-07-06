//
//  DifficultyCurve.h
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Functions.h"

@interface DifficultyCurve : NSObject <NSCoding>

@property (nonatomic, assign) CGFloat timeToGenerateSock;

-(void)reduceTimeToGenerateSock;
-(SockSize)getNextSockSize;
-(int)getNextSockType;

@end
