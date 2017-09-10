//
//  DifficultyCurve.m
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

//#import "DifficultyCurve.h"
//
//#define MAX_SOCK_SIZE (3)
//#define MAX_SOCK_TYPES (8)
//#define MAX_BELT_MOVE_MULTIPLIER_MAX (4)
//
//#define PROB_GEN_NEW_TYPE_MAX (45.0)
//#define PROB_GEN_EXIST_TYPE_EXIST_SIZE_MAX (75.0)
//
//
//@implementation DifficultyCurve {
//    CGFloat incrementToUnlockSockSize;
//    CGFloat thresholdToUnlockNextSockSize;
//    CGFloat probGenNewType;
////    CGFloat probGenExistType; //its the complement on the one above
//    CGFloat probGenExistTypeExistSize;
//}
//
//static NSString* const difficultyCurveTimeToGenerateSockKey = @"generateSock";
//static NSString* const difficultyCurveDifferentSocksKey = @"differentSocks";
//static NSString* const difficultyCurveBeltMoveSpeedMultiplierKey = @"beltSpeedMultiplier";
//static NSString* const difficultyCurveMaxSockSizeKey = @"maxSockSize";
//static NSString* const difficultyCurveSockSizeUnlockIncrementKey = @"sockSizeUnlockIncrement";
//static NSString* const difficultyCurveThresholdToUnlockNextSockSizeKey = @"thresholdToUnlockNextSockSize";
//static NSString* const difficultyCurveProbGenNewTypeKey = @"probGenNewType";
//static NSString* const difficultyCurveProbGenExistTypeExistSizeKey = @"probGenExistTypeExistSize";
//
//-(id)init{
//    self = [super init];
//    _timeToGenerateSock = 1.5;
//    _numOfDifferentSocksToGenerate = 0;
//    _beltMoveSpeedMultiplier = 2;
//    _maxSockSize = 0;
//
//    incrementToUnlockSockSize = 0;
//    thresholdToUnlockNextSockSize = 1;
//    probGenNewType = 30.0;
//    probGenExistTypeExistSize = 30.0;
//    return self;
//}
//
////TODO pass in parameters for each value
////-(id)initWithCurrentGame{
////    self = [super init];
////    _timeToGenerateSock = 1.5;
////    return self;
////}
//
//-(void)tickDifficulty {
//    //increase the difficulty a little...
//    [self tickGenerationProbabilities];
//    [self tickSockSize];
//    [self increaseBeltMoveSpeed];
//    [self reduceTimeToGenerateSock];
//    [self tickNewSock];
//}
//
//-(void)tickSockSize{
//    incrementToUnlockSockSize += [Functions randFromMin:0 toMax:0.03];
//
//    if(incrementToUnlockSockSize >= thresholdToUnlockNextSockSize){
//        if(_maxSockSize < MAX_SOCK_SIZE-1){
//            _maxSockSize += 1;
//            thresholdToUnlockNextSockSize *= 2;
//
//            if([self.delegate respondsToSelector:@selector(newSockSize)]){
////                [self.delegate newSockSize];
//            }
//        }
//
//        incrementToUnlockSockSize = 0;
//    }
//}
//
//-(void)increaseBeltMoveSpeed{
//    _beltMoveSpeedMultiplier += 0.015;
//    if(_beltMoveSpeedMultiplier >= MAX_BELT_MOVE_MULTIPLIER_MAX){
//        _beltMoveSpeedMultiplier = MAX_BELT_MOVE_MULTIPLIER_MAX;
//    }
//}
//
//-(void)reduceTimeToGenerateSock{
//    _timeToGenerateSock = _timeToGenerateSock >= 1 ? _timeToGenerateSock -= 0.025 : 1;
//}
//
//-(void)tickNewSock{
//    int oldNum = floor(_numOfDifferentSocksToGenerate);
//
//    if(_numOfDifferentSocksToGenerate >= 1){
//        //todo change the max dynamically to make it harder
////        CGFloat t = floor(_numOfDifferentSocksToGenerate)/(CGFloat)[Functions randFromMin:(10*(_numOfDifferentSocksToGenerate+1)) toMax:(14*(_numOfDifferentSocksToGenerate+1))];
////        CGFloat m = 0.1;
////        _numOfDifferentSocksToGenerate += [Functions randFromMin:0 toMax:m-(t >= m ? m : t)];
//        _numOfDifferentSocksToGenerate += [Functions randFromMin:0 toMax:0.075];
//    }else{
//        _numOfDifferentSocksToGenerate += 0.2;
//    }
//
//    if(floor(_numOfDifferentSocksToGenerate) == oldNum+1){
//        if(oldNum+1 <= MAX_SOCK_TYPES-1){
//            if([self.delegate respondsToSelector:@selector(newSockType)]){
//                [self.delegate newSockType];
//            }
//        }
//    }
//}
//
////-(SockSize)getNextSockSize {
////    return [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
////}
////
//////TODO use a #define to cap the sock limit
////-(int)getNextSockType{
////    int max = (int)_numOfDifferentSocksToGenerate;
////    return [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
////}
//
//-(void)tickGenerationProbabilities{
//    probGenNewType += 1.2;
//    if(probGenNewType >= PROB_GEN_NEW_TYPE_MAX){
//        probGenNewType = PROB_GEN_NEW_TYPE_MAX;
//    }
//
//    probGenExistTypeExistSize += 0.4;
//    if(probGenExistTypeExistSize <= PROB_GEN_EXIST_TYPE_EXIST_SIZE_MAX){
//        probGenExistTypeExistSize = PROB_GEN_EXIST_TYPE_EXIST_SIZE_MAX;
//    }
//}
//
//-(NSArray*)getNextSock:(NSMutableArray<SockData*>*)sockData{
//    int type = 0;
//
//
//    return @[@(type), @(0)];
//}
//
////-(NSArray*)getNextSock:(NSMutableArray<SockData*>*)sockData{
////
////    int max = MAX_SOCK_TYPES;//(int)_numOfDifferentSocksToGenerate;
////    int type = 0;
////    int size = 0;//[Functions randomNumberBetween:0 maxNumber:_maxSockSize];
////    NSMutableArray<NSNumber*>* types = [self getAllDifferentTypesInSockArray:sockData];
////
////    int n = [Functions randFromMin:1 toMax:100];
////    if((n <= 40/*probGenNewType*/ && types.count < max && types.count < sockData.count) || sockData.count < 1){
////        //create a random sock type that isn't already on screen
////        do {
////            type = [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
////        } while ([types containsObject:[NSNumber numberWithInt:type]]);
////        //the sock size is also random
////    }else{
////        //create a random sock with a type that already exists
////        // _Type = randomTypeThatAlreadyExists
////
////        do {
////            type = [Functions randomNumberBetween:0 maxNumber: max > MAX_SOCK_TYPES-1 ? MAX_SOCK_TYPES-1 : max];
////        } while ([types containsObject:[NSNumber numberWithInt:type]] == false);
////
////
//////      SIZE IS NOW ALWAYS MEDIUM
//////        //create a sock with a size of any sock that is _Type (this always produces a pair to a sock)
//////        if([Functions randFromMin:1 toMax:100] <= 40){
//////            NSMutableArray<NSNumber*>* sizes = [self getAllSockSizesForSockType:sockData type:type];
//////
//////            do {
//////                size = [Functions randomNumberBetween:0 maxNumber:_maxSockSize];
//////            } while ([sizes containsObject:[NSNumber numberWithInt:size]] == false);
//////
//////        }else{
//////            //create a random sock size (that doesn't already exist?)
//////
//////            // (this is already done when the size variable is initiated)
//////        }
////    }
////
////
////    return @[@(type), @(size)];
////}
//
//-(NSMutableArray<NSNumber*>*)getAllDifferentTypesInSockArray:(NSMutableArray<SockData*>*)data{
//    NSMutableArray<NSNumber*>* types = [[NSMutableArray alloc] init];
//
//    for(SockData* d in data){
//        NSNumber* t = [NSNumber numberWithInt:d.sockId];
//        if([types containsObject:t] == false){
//            [types addObject:t];
//        }
//    }
//    return types;
//}
//
//-(NSMutableArray<NSNumber*>*)getAllSockSizesForSockType:(NSMutableArray<SockData*>*)data type:(int)type{
//    NSMutableArray<NSNumber*>* sizes = [[NSMutableArray alloc] init];
//
//    for(SockData* d in data){
//        NSNumber* s = [NSNumber numberWithInt:d.sockSize];
//        if(d.sockId == type && [sizes containsObject:s] == false){
//            [sizes addObject:s];
//        }
//    }
//    return sizes;
//}
//
//-(instancetype)initWithCoder:(NSCoder *)decoder{
//    self = [self init];
//    if(self){
//        _timeToGenerateSock = [decoder decodeFloatForKey:difficultyCurveTimeToGenerateSockKey];
//        _numOfDifferentSocksToGenerate = [decoder decodeFloatForKey:difficultyCurveDifferentSocksKey];
//        _beltMoveSpeedMultiplier = [decoder decodeFloatForKey:difficultyCurveBeltMoveSpeedMultiplierKey];
//        _maxSockSize = [decoder decodeIntForKey:difficultyCurveMaxSockSizeKey];
//        incrementToUnlockSockSize = [decoder decodeFloatForKey:difficultyCurveSockSizeUnlockIncrementKey];
//        thresholdToUnlockNextSockSize = [decoder decodeFloatForKey:difficultyCurveThresholdToUnlockNextSockSizeKey];
//        probGenNewType = [decoder decodeFloatForKey:difficultyCurveProbGenNewTypeKey];
//        probGenExistTypeExistSize = [decoder decodeFloatForKey:difficultyCurveProbGenExistTypeExistSizeKey];
//    }
//    return self;
//}
//
//-(void)encodeWithCoder:(NSCoder *)encoder{
//    [encoder encodeFloat:self.timeToGenerateSock forKey:difficultyCurveTimeToGenerateSockKey];
//    [encoder encodeFloat:self.numOfDifferentSocksToGenerate forKey:difficultyCurveDifferentSocksKey];
//    [encoder encodeFloat:self.beltMoveSpeedMultiplier forKey:difficultyCurveBeltMoveSpeedMultiplierKey];
//    [encoder encodeInt:self.maxSockSize forKey:difficultyCurveMaxSockSizeKey];
//    [encoder encodeFloat:incrementToUnlockSockSize forKey:difficultyCurveSockSizeUnlockIncrementKey];
//    [encoder encodeFloat:thresholdToUnlockNextSockSize forKey:difficultyCurveThresholdToUnlockNextSockSizeKey];
//    [encoder encodeFloat:probGenNewType forKey:difficultyCurveProbGenNewTypeKey];
//    [encoder encodeFloat:probGenExistTypeExistSize forKey:difficultyCurveProbGenExistTypeExistSizeKey];
//}
//
//@end

#import "DifficultyCurve.h"

#define MAX_SOCK_TYPES (18)
#define MAX_BELT_MOVE_MULTIPLIER_MAX (3.2)

@implementation DifficultyCurve {
    CGFloat probGenNewType;
    //    CGFloat probGenExistType; //its the complement on the one above
    CGFloat probGenExistTypeExistSize;
}

static NSString* const difficultyCurveTimeToGenerateSockKey = @"generateSock";
static NSString* const difficultyCurveBeltMoveSpeedMultiplierKey = @"beltSpeedMultiplier";
static NSString* const difficultyCurveMaxSockSizeKey = @"maxSockSize";
static NSString* const difficultyCurveSockSizeUnlockIncrementKey = @"sockSizeUnlockIncrement";
static NSString* const difficultyCurveThresholdToUnlockNextSockSizeKey = @"thresholdToUnlockNextSockSize";
static NSString* const difficultyCurveProbGenNewTypeKey = @"probGenNewType";
static NSString* const difficultyCurveProbGenExistTypeExistSizeKey = @"probGenExistTypeExistSize";

-(id)init{
    self = [super init];
    _timeToGenerateSock = 0.9;
    _beltMoveSpeedMultiplier = 1;
    _maxSockSize = 0;
    
    probGenNewType = 30.0;
    probGenExistTypeExistSize = 30.0;
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
    _timeToGenerateSock = _timeToGenerateSock > 0.5 ? _timeToGenerateSock-0.05 : 0.5;
    [self increaseBeltMoveSpeed];
    [self reduceTimeToGenerateSock];
}

-(void)increaseBeltMoveSpeed{
    _beltMoveSpeedMultiplier += 0.015;
    if(_beltMoveSpeedMultiplier >= MAX_BELT_MOVE_MULTIPLIER_MAX){
        _beltMoveSpeedMultiplier = MAX_BELT_MOVE_MULTIPLIER_MAX;
    }
}

-(void)reduceTimeToGenerateSock{
    _timeToGenerateSock = _timeToGenerateSock >= 1 ? _timeToGenerateSock -= 0.025 : 1;
}

-(NSArray*)getNextSock:(NSMutableArray<SockData*>*)sockData{
    int type = [Functions randomNumberBetween:0 maxNumber:MAX_SOCK_TYPES-1];
    
    
    return @[@(type), @(0)];
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
        _beltMoveSpeedMultiplier = [decoder decodeFloatForKey:difficultyCurveBeltMoveSpeedMultiplierKey];
        _maxSockSize = [decoder decodeIntForKey:difficultyCurveMaxSockSizeKey];
        probGenNewType = [decoder decodeFloatForKey:difficultyCurveProbGenNewTypeKey];
        probGenExistTypeExistSize = [decoder decodeFloatForKey:difficultyCurveProbGenExistTypeExistSizeKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeFloat:self.timeToGenerateSock forKey:difficultyCurveTimeToGenerateSockKey];
    [encoder encodeFloat:self.beltMoveSpeedMultiplier forKey:difficultyCurveBeltMoveSpeedMultiplierKey];
    [encoder encodeInt:self.maxSockSize forKey:difficultyCurveMaxSockSizeKey];
    [encoder encodeFloat:probGenNewType forKey:difficultyCurveProbGenNewTypeKey];
    [encoder encodeFloat:probGenExistTypeExistSize forKey:difficultyCurveProbGenExistTypeExistSizeKey];
}

@end


