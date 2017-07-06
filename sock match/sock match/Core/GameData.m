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
static NSString* const gameDataEfficiencyKey = @"efficiency";
static NSString* const gameDataSocksKey = @"socks";
static NSString* const gameDataDifficultyCurveKey = @"difficultyCurve";

-(id)init{
    self = [super init];
    _efficiency = 100.0;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        _score = [decoder decodeIntForKey: gameDataHighScoreKey];
        _efficiency = [decoder decodeIntForKey:gameDataEfficiencyKey];
        _sockData = [decoder decodeObjectForKey: gameDataSocksKey];
        _difficultyCurve = [decoder decodeObjectForKey:gameDataDifficultyCurveKey];
    }
    return self;
}

+(instancetype)loadInstance {
    NSData* decodedData = [NSData dataWithContentsOfFile: [GameData filePath]];
    if (decodedData) {
        GameData* gameData = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
        return gameData;
    }
    
    return [[GameData alloc] init];
}

-(void)saveGameWithScore:(int)score efficiency:(int)efficiency socks:(NSMutableArray<SockData*>*)sockData andDifficulty:(DifficultyCurve *)difficultyCurve {
    self.score = score;
    self.efficiency = efficiency;
    self.sockData = sockData;
    self.difficultyCurve = difficultyCurve;
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
    [encoder encodeInt: self.efficiency forKey:gameDataEfficiencyKey];
    [encoder encodeObject: self.sockData forKey: gameDataSocksKey];
    [encoder encodeObject: self.difficultyCurve forKey:gameDataDifficultyCurveKey];
}

-(void)clearSave {
    self.score = 0;
    self.efficiency = 100.0;
    self.sockData = [[NSMutableArray alloc] init];
    self.difficultyCurve = [[DifficultyCurve alloc] init];
    [self saveGameWithScore:self.score efficiency:self.efficiency socks:self.sockData andDifficulty:self.difficultyCurve];
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
