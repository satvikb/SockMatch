//
//  GameOverViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameOverTransition;

@interface GameOverViewController : UIViewController<UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<GameOverTransition> delegate;
-(void)setScore:(int)score;
@end

@protocol GameOverTransition <NSObject>
- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver;
@end
