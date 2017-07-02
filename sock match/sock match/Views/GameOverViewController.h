//
//  GameOverViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"
#import "Button.h"

@protocol GameOverDelegate;

@interface GameOverViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, strong) id<GameOverDelegate> delegate;
-(void)setScore:(int)score;
@end

@protocol GameOverDelegate <NSObject>
- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver;
- (void)reportGCScore:(int)currentScore;
@end



