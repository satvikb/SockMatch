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

@property (nonatomic, strong) NSMutableArray<Forklift*>* forklifts;

@property (nonatomic, strong) UIImageView* settingsTitle;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) Button* backButton;


-(id)initWithForkliftAnimation:(NSMutableArray<UIImage*>*)forklift andWheel:(NSMutableArray<UIImage*>*)wheels sockPackages:(NSMutableArray<UIImage*>*)packages boxImage:(UIImage*)boxImage;
//-(void) gameFrame:(CADisplayLink*)tmr;
//-(void)handleForkliftAnimation:(CGFloat)delta;

@end

@protocol SettingsDelegate <NSObject>
-(void)switchFromSettingsToMenu:(SettingsViewController*) settings;
//-(void)menuGameCenterButton;
@end

