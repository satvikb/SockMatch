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

typedef enum GameState {
    NotPlaying = 0,
    WarmingUp = 1,
    Playing = 2,
    Stopping = 3
} GameState;

@property (nonatomic, weak) id<GameHandler> gameHandler;
@property (nonatomic, assign) CGFloat beltMoveSpeed;
@property (nonatomic, assign) CGFloat animateBeltMoveSpeed;
@property (nonatomic, assign) GameState currentGameState;

-(void)startGame;
-(void) gameFrame:(CADisplayLink*)tmr;
-(void)switchGameStateTo:(GameState)newGameState;

@end

@protocol GameHandler <NSObject>
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
@end
