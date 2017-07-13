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

#define PROB_GEN_NEW_TYPE_MAX (45.0)
#define PROB_GEN_EXIST_TYPE_EXIST_SIZE_MIN (25.0)


@implementation DifficultyCurve {
    CGFloat incrementToUnlockSockSize;
    CGFloat thresholdToUnlockNextSockSize;
    CGFloat probGenNewType;
//    CGFloat probGenExistType; //its the complement on the one above
    CGFloat probGenExistTypeExistSize;
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
    thresholdToUnlockNextSockSize = 1;
    probGenNewType = 30.0;
    probGenExistTypeExistSize = 40.0;
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
    [self tickGenerationProbabilities];
    [self tickSockSize];
    [self increaseBeltMoveSpeed];
    [self reduceTimeToGenerateSock];
    [self tickNewSock];
}

-(void)tickSockSize{
    incrementToUnlockSockSize += [Functions randFromMin:0 toMax:0.03];
    
    if(incrementToUnlockSockSize >= thresholdToUnlockNextSockSize){
        if(_maxSockSize < MAX_SOCK_SIZE-1){
            _maxSockSize += 1;
            thresholdToUnlockNextSockSize *= 2;
            
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
    //todo change the max dynamically to make it harder
    _numOfDifferentSocksToGenerate += [Functions randFromMin:0 toMax:0.025];
    
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

-(void)tickGenerationProbabilities{
    probGenNewType += 1.2;
    if(probGenNewType >= PROB_GEN_NEW_TYPE_MAX){
        probGenNewType = PROB_GEN_NEW_TYPE_MAX;
    }
    
    probGenExistTypeExistSize -= 0.8;
    if(probGenExistTypeExistSize <= PROB_GEN_EXIST_TYPE_EXIST_SIZE_MIN){
        probGenExistTypeExistSize = PROB_GEN_EXIST_TYPE_EXIST_SIZE_MIN;
    }
}

-(NSArray*)getNextSock:(NSMutableArray<SockData*>*)sockData{
    
    int max = (int)_numOfDifferentSocksToGenerate;
    int type = 0;
    int size = [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
    NSMutableArray<NSNumber*>* types = [self getAllDifferentTypesInSockArray:sockData];
    
    //todo maybe use types.count < max-1
    int n = [Functions randFromMin:1 toMax:100];
    if((n <= probGenNewType && types.count <= max && types.count < sockData.count) || sockData.count < 1){
        //create a random sock type that isn't already on screen
        do {
            type = [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
        } while ([types containsObject:[NSNumber numberWithInt:type]]);
        //the sock size is also random
    }else{
        //create a random sock with a type that already exists
        // _Type = randomTypeThatAlreadyExists
        
        do {
            type = [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
        } while ([types containsObject:[NSNumber numberWithInt:type]] == false);
        
        //create a sock with a size of any sock that is _Type (this always produces a pair to a sock)
        if([Functions randFromMin:1 toMax:100] <= probGenExistTypeExistSize){
            NSMutableArray<NSNumber*>* sizes = [self getAllSockSizesForSockType:sockData type:type];
            
            do {
                size = [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
            } while ([sizes containsObject:[NSNumber numberWithInt:size]] == false);
            
        }else{
            //create a random sock size (that doesn't already exist?)
            
            // (this is already done when the size variable is initiated)
        }
    }
    
    
    return @[@(type), @(size)];
}

-(NSMutableArray<NSNumber*>*)getAllDifferentTypesInSockArray:(NSMutableArray<SockData*>*)data{
    NSMutableArray<NSNumber*>* types = [[NSMutableArray alloc] init];
    
    for(SockData* d in data){
        NSNumber* t = [NSNumber numberWithInt:d.sockId];
        if([types containsObject:t] == false){
            [types addObject:t];
        }
    }
    return types;
}

-(NSMutableArray<NSNumber*>*)getAllSockSizesForSockType:(NSMutableArray<SockData*>*)data type:(int)type{
    NSMutableArray<NSNumber*>* sizes = [[NSMutableArray alloc] init];
    
    for(SockData* d in data){
        NSNumber* s = [NSNumber numberWithInt:d.sockSize];
        if(d.sockId == type && [sizes containsObject:s] == false){
            [sizes addObject:s];
        }
    }
    return sizes;
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
