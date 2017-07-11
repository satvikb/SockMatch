//
//  DifficultyCurve.m
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "DifficultyCurve.h"

#define MAX_SOCK_SIZE (3)
#define MAX_SOCK_TYPES (8)
#define MAX_BELT_MOVE_MULTIPLIER (4)

@implementation DifficultyCurve {
    CGFloat incrementToUnlockSockSize;
}

static NSString* const difficultyCurveTimeToGenerateSockKey = @"generateSock";
static NSString* const difficultyCurveDifferentSocksKey = @"differentSocks";
static NSString* const difficultyCurveBeltMoveSpeedMultiplierKey = @"beltSpeedMultiplier";
static NSString* const difficultyCurveMaxSockSizeKey = @"maxSockSize";
static NSString* const difficultyCurveSockSizeUnlockIncrementKey = @"sockSizeUnlockIncrement";

-(id)init{
    self = [super init];
    _timeToGenerateSock = 1.5;
    _numOfDifferentSocksToGenerate = 0;
    _beltMoveSpeedMultiplier = 1;
    _maxSockSize = 0;
    incrementToUnlockSockSize = 0;
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
    [self tickSockSize];
    [self increaseBeltMoveSpeed];
    [self reduceTimeToGenerateSock];
    [self tickNewSock];
}

-(void)tickSockSize{
    incrementToUnlockSockSize += [Functions randFromMin:0 toMax:0.04];
    
    if(incrementToUnlockSockSize >= 1){
        if(_maxSockSize < MAX_SOCK_SIZE-1){
            _maxSockSize += 1;
            
            if([self.delegate respondsToSelector:@selector(newSockSize)]){
                [self.delegate newSockSize];
            }
        }
        
        incrementToUnlockSockSize = 0;
    }
}

-(void)increaseBeltMoveSpeed{
    _beltMoveSpeedMultiplier += 0.01;
    if(_beltMoveSpeedMultiplier >= MAX_BELT_MOVE_MULTIPLIER){
        _beltMoveSpeedMultiplier = MAX_BELT_MOVE_MULTIPLIER;
    }
}

-(void)reduceTimeToGenerateSock{
    _timeToGenerateSock = _timeToGenerateSock >= 1 ? _timeToGenerateSock -= 0.025 : 1;
}

-(void)tickNewSock{
    int oldNum = floor(_numOfDifferentSocksToGenerate);
    _numOfDifferentSocksToGenerate += [Functions randFromMin:0 toMax:0.2];
    
    if(floor(_numOfDifferentSocksToGenerate) == oldNum+1){
        if(oldNum+1 <= MAX_SOCK_TYPES-1){
            if([self.delegate respondsToSelector:@selector(newSockType)]){
                [self.delegate newSockType];
            }
        }
    }
}

//-(SockSize)getNextSockSize {
//    return [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
//}
//
////TODO use a #define to cap the sock limit
//-(int)getNextSockType{
//    int max = (int)_numOfDifferentSocksToGenerate;
//    return [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
//}

-(NSArray*)getNextSock:(NSMutableArray<Sock*>*)socks{
    int max = (int)_numOfDifferentSocksToGenerate;
    int type = [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
    int size = [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
    
    return @[@(type), @(size)];
}

-(instancetype)initWithCoder:(NSCoder *)decoder{
    self = [self init];
    if(self){
        _timeToGenerateSock = [decoder decodeFloatForKey:difficultyCurveTimeToGenerateSockKey];
        _numOfDifferentSocksToGenerate = [decoder decodeFloatForKey:difficultyCurveDifferentSocksKey];
        _beltMoveSpeedMultiplier = [decoder decodeFloatForKey:difficultyCurveBeltMoveSpeedMultiplierKey];
        _maxSockSize = [decoder decodeIntForKey:difficultyCurveMaxSockSizeKey];
        incrementToUnlockSockSize = [decoder decodeFloatForKey:difficultyCurveSockSizeUnlockIncrementKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeFloat:self.timeToGenerateSock forKey:difficultyCurveTimeToGenerateSockKey];
    [encoder encodeFloat:self.numOfDifferentSocksToGenerate forKey:difficultyCurveDifferentSocksKey];
    [encoder encodeFloat:self.beltMoveSpeedMultiplier forKey:difficultyCurveBeltMoveSpeedMultiplierKey];
    [encoder encodeInt:self.maxSockSize forKey:difficultyCurveMaxSockSizeKey];
    [encoder encodeFloat:incrementToUnlockSockSize forKey:difficultyCurveSockSizeUnlockIncrementKey];
}

@end
