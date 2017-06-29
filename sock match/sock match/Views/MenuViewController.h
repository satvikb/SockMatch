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

@protocol MenuDelegate;

@interface MenuViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id<MenuDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<Forklift*>* forklifts;

@property (nonatomic, strong) UIImageView* gameTitle;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, strong) UIImageView* playButton;
@property (nonatomic, strong) UIImageView* gameCenterButton;

-(id)initWithForkliftAnimation:(NSMutableArray<UIImage*>*)forklift andWheel:(NSMutableArray<UIImage*>*)wheels sockPackages:(NSMutableArray<UIImage*>*)packages;
-(void) gameFrame:(CADisplayLink*)tmr;

@end

@protocol MenuDelegate <NSObject>
-(int)getAppState;
-(void)switchFromMenuToGame:(MenuViewController*) menu;
-(void)menuGameCenterButton;
@end
