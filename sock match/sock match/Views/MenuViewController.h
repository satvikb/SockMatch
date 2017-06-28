//
//  MenuViewController.h
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuDelegate;

@interface MenuViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id<MenuDelegate> delegate;
@property (nonatomic, strong) UIImageView* gameTitle;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) UIImageView* playButton;
@property (nonatomic, strong) UIImageView* gameCenterButton;

@end

@protocol MenuDelegate <NSObject>
-(void)switchFromMenuToGame:(MenuViewController*) menu;
-(void)menuGameCenterButton;
@end
