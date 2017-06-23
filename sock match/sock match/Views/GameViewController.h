//
//  GameViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Claw.h"

@protocol GameHandler;

@interface GameViewController : UIViewController{
    
}

@property (nonatomic, weak) id<GameHandler> gameHandler;
@property (nonatomic, assign) CGFloat beltMoveSpeed;

-(void)warmupGame;
-(void)beginGame;
-(void)endGame;
-(void)stopGameLoop;
@end

@protocol GameHandler <NSObject>
- (void) gameLoop:(CGFloat)delta;
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
@end
