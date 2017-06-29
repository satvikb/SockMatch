//
//  GameViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"
#import "Claw.h"
#import "Forklift.h"
#import "Functions.h"
#import "SockTouch.h"

@protocol GameDelegate;

@interface GameViewController : UIViewController{
    
}

typedef enum GameState {
    NotPlaying = 0,
    WarmingUp = 1,
    Playing = 2,
    Stopping = 3
} GameState;

@property (nonatomic, strong) id<GameDelegate> delegate;
@property (nonatomic, assign) CGFloat beltMoveSpeed;
@property (nonatomic, assign) CGFloat animateBeltMoveSpeed;
@property (nonatomic, assign) GameState currentGameState;

-(void)startGame;
-(void) gameFrame:(CADisplayLink*)tmr;
-(void)switchGameStateTo:(GameState)newGameState;

@end

@protocol GameDelegate <NSObject>
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
@end
