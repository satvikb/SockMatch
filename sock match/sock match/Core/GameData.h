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
@property (assign, nonatomic) CGFloat efficiency;
@property (strong, nonatomic) NSMutableArray<SockData*>* sockData;

+(instancetype)sharedGameData;
+(NSString*)filePath;
-(void)saveGameWithScore:(int)score efficiency:(int)efficiency andSocks:(NSMutableArray<SockData*>*)sockData;
-(void)clearSave;

@end
