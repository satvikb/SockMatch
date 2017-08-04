//
//  MenuViewController.h
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Forklift.h"
#import "Functions.h"
#import "Button.h"

@protocol MenuDelegate;

@interface MenuViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id<MenuDelegate> delegate;

@property (nonatomic, strong) UIImageView* gameTitle;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) Button* playButton;
@property (nonatomic, strong) UIImageView* gameCenterButton;
@property (nonatomic, strong) UIImageView* settingsButton;

@property (nonatomic, strong) UILabel* highScoreLabel;

@end

@protocol MenuDelegate <NSObject>
-(int)getAppState;
-(void)switchFromMenuToGame:(MenuViewController*) menu;
-(void)switchFromMenuToSettings:(MenuViewController*) menu;
-(void)menuGameCenterButton;
@end
