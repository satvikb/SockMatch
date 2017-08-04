//
//  SettingsViewController.h
//  sock match
//
//  Created by Satvik Borra on 8/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forklift.h"
#import "Functions.h"
#import "Button.h"
#import "Settings.h"
#import "SettingView.h"

@protocol SettingsDelegate;

@interface SettingsViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id<SettingsDelegate> delegate;

@property (nonatomic, strong) UIImageView* settingsTitle;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) Button* backButton;

@end

@protocol SettingsDelegate <NSObject>
-(void)switchFromSettingsToMenu:(SettingsViewController*) settings;
-(void)settingChanged:(SettingTypes)type;
//-(void)menuGameCenterButton;
@end

