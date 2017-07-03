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
@property (assign, nonatomic) int lives;
@property (strong, nonatomic) NSMutableArray<SockData*>* sockData;

+(instancetype)sharedGameData;
-(void)saveGameWithScore:(int)score lives:(int)lives andSocks:(NSMutableArray<SockData*>*)sockData;
-(void)clearSave;

@end
