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

static NSString* const completeTutorialKey = @"completeTutorial";

+(bool)didCompleteTutorial {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:completeTutorialKey] == NO){
        return false;
    }
    return true;
}

+(void)completeTutorial{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:completeTutorialKey];
}

@end
