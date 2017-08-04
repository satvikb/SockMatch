//
//  Settings.h
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

typedef enum SettingTypes {
    Sound = 0,
    GameAlertSockType,
    GameAlertSockSize,    
} SettingTypes;

+ (instancetype)sharedInstance;
-(NSString*)getSettingTextForType:(SettingTypes)type;
-(void)toggleSetting:(SettingTypes)settingType;
-(bool)getCurrentSetting:(SettingTypes)settingType;

@property (nonatomic, assign) bool soundsEnabled;
@property (nonatomic, assign) bool sockTypeAlertEnabled;
@property (nonatomic, assign) bool sockSizeAlertEnabled;


@end
