//
//  GameData.m
//  sock match
//
//  Created by Satvik Borra on 7/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameData.h"

@implementation GameData

static NSString* const gameDataHighScoreKey = @"score";
static NSString* const gameDataSocksKey = @"socks";

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _score = [decoder decodeIntForKey: gameDataHighScoreKey];
        _sockData = [decoder decodeObjectForKey: gameDataSocksKey];
    }
    return self;
}

+(instancetype)loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];//[NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[GameData alloc] init];
}

-(void)save:(int)score socks:(NSMutableArray<SockData*>*)sockData {
    self.score = score;
    self.sockData = sockData;
    NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject: self];
    [encodedData writeToFile:[GameData filePath] atomically:YES];
}

+ (instancetype)sharedGameData {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self loadInstance];
    });
    
    return sharedInstance;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt: self.score forKey: gameDataHighScoreKey];
    [encoder encodeObject: self.sockData forKey: gameDataSocksKey];
}

-(void)reset {
    self.score = 0;
    self.sockData = [[NSMutableArray alloc] init];
}

+(NSString*)filePath
{
    static NSString* filePath = nil;
    if (!filePath) {
        filePath =
        [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
         stringByAppendingPathComponent:@"gamedata"];
    }
    return filePath;
}

@end
