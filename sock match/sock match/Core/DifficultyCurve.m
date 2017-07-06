//
//  DifficultyCurve.m
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "DifficultyCurve.h"

@implementation DifficultyCurve

static NSString* const difficultyCurveTimeToGenerateSockKey = @"generateSock";

-(id)init{
    self = [super init];
    _timeToGenerateSock = 1.5;
    return self;
}

//TODO pass in parameters for each value
-(id)initWithCurrentGame{
    self = [super init];
    _timeToGenerateSock = 1.5;
    return self;
}

-(void)tickDifficulty {
    //increase the difficulty a little...
    
}

-(void)reduceTimeToGenerateSock{
    _timeToGenerateSock = _timeToGenerateSock >= 1 ? _timeToGenerateSock -= 0.025 : 1;
}

-(SockSize)getNextSockSize {
    return [Functions randomNumberBetween:1 maxNumber:1];
}

-(int)getNextSockType{
    return [Functions randomNumberBetween:0 maxNumber:4];
}

-(instancetype)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if(self){
        _timeToGenerateSock = [decoder decodeFloatForKey:difficultyCurveTimeToGenerateSockKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeFloat:self.timeToGenerateSock forKey:difficultyCurveTimeToGenerateSockKey];
}

@end
