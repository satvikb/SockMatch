//
//  DifficultyCurve.h
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Functions.h"
#import "SockData.h"

@protocol DifficultyDelegate;

@interface DifficultyCurve : NSObject <NSCoding>

@property (nonatomic, strong) id<DifficultyDelegate> delegate;
@property (nonatomic, assign) CGFloat beltMoveSpeedMultiplier;
@property (nonatomic, assign) CGFloat timeToGenerateSock;
@property (nonatomic, assign) CGFloat numOfDifferentSocksToGenerate;
@property (nonatomic, assign) int maxSockSize;

-(void)tickDifficulty;
-(void)reduceTimeToGenerateSock;
//-(SockSize)getNextSockSize;
//-(int)getNextSockType;
-(NSArray*)getNextSock:(NSMutableArray<SockData*>*)sockData;

@end

@protocol DifficultyDelegate <NSObject>
- (void) newSockSize;
- (void) newSockType;
@end
