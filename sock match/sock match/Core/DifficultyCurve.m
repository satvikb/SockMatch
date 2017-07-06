//
//  DifficultyCurve.m
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "DifficultyCurve.h"

@implementation DifficultyCurve

-(id)initWithCurrentGame{
    self = [super init];
                          
    return self;
}

-(void)tickDifficulty {
    //increase the difficulty a little...
    
}

-(SockSize)getNextSockSize {
    return [Functions randomNumberBetween:1 maxNumber:1];
}

-(int)getNextSockType{
    return [Functions randomNumberBetween:0 maxNumber:4];
}

-(instancetype)initWithCoder:(NSCoder *)decoder{
    return [self init];
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    
}

@end
