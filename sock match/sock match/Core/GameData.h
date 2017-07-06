//
//  GameData.h
//  sock match
//
//  Created by Satvik Borra on 7/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SockData.h"
#import "DifficultyCurve.h"
@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) int score;
@property (assign, nonatomic) CGFloat efficiency;
@property (strong, nonatomic) NSMutableArray<SockData*>* sockData;
@property (strong, nonatomic) DifficultyCurve* difficultyCurve;

+(instancetype)sharedGameData;
+(NSString*)filePath;
-(void)saveGameWithScore:(int)score efficiency:(int)efficiency socks:(NSMutableArray<SockData*>*)sockData andDifficulty:(DifficultyCurve*)difficultyCurve;
-(void)clearSave;

@end
