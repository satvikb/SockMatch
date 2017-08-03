//
//  Settings.m
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Settings.h"

@implementation Settings


+ (instancetype)sharedInstance
{
    static Settings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Settings alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

-(NSString*)getSettingTextForType:(SettingTypes)type{
    switch (type) {
        case Sound:
            return @"Sound Effects";
            break;
        case GameAlertSockType:
            return @"New sock type alerts";
        case GameAlertSockSize:
            return @"New sock size alerts";
    }
}

@end
