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

@protocol GameDelegate;

@interface GameViewController : UIViewController{
    
}

@property (nonatomic, strong) id<GameDelegate> delegate;
@property (nonatomic, assign) CGFloat beltMoveSpeed;
@property (nonatomic, assign) CGFloat animateBeltMoveSpeed;
@property (nonatomic, assign) GameState currentGameState;

@property (strong, nonatomic) NSMutableArray<UIImage*>* sockMainImages;
@property (strong, nonatomic) NSMutableArray<UIImage*>* sockPackages;
@property (strong, nonatomic) NSMutableArray<UIImage*>* scoreDigitImages;

@property (strong, nonatomic) NSMutableArray<UIImage*>* boxAnimationFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* wheelFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* clawAnimationFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* forkLiftAnimationFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* emissionAnimationFrames;

-(void)startGame;
-(void) gameFrame:(CADisplayLink*)tmr;
-(void)switchGameStateTo:(GameState)newGameState;
-(void) setScoreImages:(int)s;

@end

@protocol GameDelegate <NSObject>
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
@end
