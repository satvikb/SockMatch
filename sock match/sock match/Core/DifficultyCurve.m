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
static NSString* const difficultyCurveDifferentSocksKey = @"differentSocks";

-(id)init{
    self = [super init];
    _timeToGenerateSock = 1.5;
    _numOfDifferentSocksToGenerate = 1;
    return self;
}

//TODO pass in parameters for each value
//-(id)initWithCurrentGame{
//    self = [super init];
//    _timeToGenerateSock = 1.5;
//    return self;
//}

-(void)tickDifficulty {
    //increase the difficulty a little...
    
    [self reduceTimeToGenerateSock];
}

-(void)reduceTimeToGenerateSock{
    _timeToGenerateSock = _timeToGenerateSock >= 1 ? _timeToGenerateSock -= 0.025 : 1;
    
    int oldNum = floor(_numOfDifferentSocksToGenerate);
    _numOfDifferentSocksToGenerate += 0.5;
    
    if(floor(_numOfDifferentSocksToGenerate) == oldNum+1){
        NSLog(@"new sock@");
        if([self.delegate respondsToSelector:@selector(newSockType)]){
            [self.delegate newSockType];
        }
    }
}

-(SockSize)getNextSockSize {
    return [Functions randomNumberBetween:1 maxNumber:1];
}

//TODO use a #define to cap the sock limit
-(int)getNextSockType{
    int max = (int)_numOfDifferentSocksToGenerate;
    return [Functions randomNumberBetween:0 maxNumber: max > 5 ? 5 : max];
}

-(instancetype)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if(self){
        _timeToGenerateSock = [decoder decodeFloatForKey:difficultyCurveTimeToGenerateSockKey];
        _numOfDifferentSocksToGenerate = [decoder decodeFloatForKey:difficultyCurveDifferentSocksKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeFloat:self.timeToGenerateSock forKey:difficultyCurveTimeToGenerateSockKey];
    [encoder encodeFloat:self.numOfDifferentSocksToGenerate forKey:difficultyCurveDifferentSocksKey];
}

@end
