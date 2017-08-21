//
//  Settings.m
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Settings.h"

#define SoundEnabledKey  @"soundEnabled"
#define SockTypeAlertEnabledKey  @"sockTypeAlert"
#define SockSizeAlertEnabledKey  @"sockSizeAlert"

@implementation Settings

@synthesize soundsEnabled;
@synthesize sockTypeAlertEnabled;
@synthesize sockSizeAlertEnabled;

+ (instancetype)sharedInstance
{
    static Settings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Settings alloc] init];
        // Do any other initialisation stuff here
        if([[NSUserDefaults standardUserDefaults] objectForKey:SoundEnabledKey] != nil){
            sharedInstance.soundsEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SoundEnabledKey];
        }else{
            sharedInstance.soundsEnabled = false;
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:SoundEnabledKey];
        }
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:SockTypeAlertEnabledKey] != nil){
            sharedInstance.sockTypeAlertEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SockTypeAlertEnabledKey];
        }else{
            sharedInstance.sockTypeAlertEnabled = false;
            [[NSUserDefaults standardUserDefaults] setBool:false forKey:SockTypeAlertEnabledKey];
        }
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:SockSizeAlertEnabledKey] != nil){
            sharedInstance.sockSizeAlertEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:SockSizeAlertEnabledKey];
        }else{
            sharedInstance.sockSizeAlertEnabled = true;
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:SockSizeAlertEnabledKey];
        }
        
    });
    return sharedInstance;
}

-(NSString*)getSettingTextForType:(SettingTypes)type{
    switch (type) {
        case Sound:
            return @"Sound (plz dont)";
        case GameAlertSockType:
            return @"Sock type alerts";
        case GameAlertSockSize:
            return @"Sock size alerts";
    }
}

-(void)toggleSetting:(SettingTypes)settingType{
    switch (settingType) {
        case Sound:
            soundsEnabled = !soundsEnabled;
            [[NSUserDefaults standardUserDefaults] setBool:soundsEnabled forKey:SoundEnabledKey];
            break;
        case GameAlertSockType:
            sockTypeAlertEnabled = !sockTypeAlertEnabled;
            [[NSUserDefaults standardUserDefaults] setBool:sockTypeAlertEnabled forKey:SockTypeAlertEnabledKey];
            break;
        case GameAlertSockSize:
            sockSizeAlertEnabled = !sockSizeAlertEnabled;
            [[NSUserDefaults standardUserDefaults] setBool:sockSizeAlertEnabled forKey:SockSizeAlertEnabledKey];
            break;
    }
}

-(bool)getCurrentSetting:(SettingTypes)settingType{
    switch (settingType) {
        case Sound:
            return soundsEnabled;
        case GameAlertSockType:
            return sockTypeAlertEnabled;
        case GameAlertSockSize:
            return sockSizeAlertEnabled;
    }
}

@end
