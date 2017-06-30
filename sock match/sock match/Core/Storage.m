//
//  Storage.m
//  sock match
//
//  Created by Satvik Borra on 6/29/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Storage.h"

@implementation Storage{
    
}

+(void)saveHighScore:(int)score{
//    NSInteger* s = [NSInteger numberWithInt:score];
    int currentHighScore = [self getSavedHighScore];
    if(currentHighScore < score){
        NSNumber* s = [NSNumber numberWithInt:score];
        [Lockbox archiveObject:s forKey:@"highscore"];
    }
}

+(int)getSavedHighScore {
    NSNumber* currentHighScore = [Lockbox unarchiveObjectForKey:@"highscore"];
    if(currentHighScore == nil){
        return 0;
    }
    return currentHighScore.intValue;
}

static NSString* const firstLaunchKey = @"firstLaunch";

+(bool)isFirstLaunch {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:firstLaunchKey] == NO){
        return true;
    }
    return false;
}

+(void)setFirstLaunch{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:firstLaunchKey];
}

@end
