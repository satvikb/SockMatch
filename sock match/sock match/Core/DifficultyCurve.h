//
//  DifficultyCurve.h
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Functions.h"

@protocol DifficultyDelegate;

@interface DifficultyCurve : NSObject <NSCoding>

@property (nonatomic, strong) id<DifficultyDelegate> delegate;
@property (nonatomic, assign) CGFloat timeToGenerateSock;
@property (nonatomic, assign) CGFloat numOfDifferentSocksToGenerate;

-(void)tickDifficulty;
-(void)reduceTimeToGenerateSock;
-(SockSize)getNextSockSize;
-(int)getNextSockType;

@end

@protocol DifficultyDelegate <NSObject>
- (void) newSockType;
@end
