//
//  GameData.h
//  sock match
//
//  Created by Satvik Borra on 7/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SockData.h"

@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) int score;
@property (strong, nonatomic) NSMutableArray<SockData*>* sockData;
+(instancetype)sharedGameData;
-(void)save:(int)score socks:(NSMutableArray<SockData*>*)sockData;
-(void)reset;

@end
