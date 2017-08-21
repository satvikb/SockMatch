//
//  GameViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"
#import "Forklift.h"
#import "Functions.h"
#import "TutorialView.h"
#import "GameData.h"
#import "Countdown.h"
#import "EfficiencyBar.h"
#import "DifficultyCurve.h"
#import "TouchImage.h"
#import "InfoBanner.h"
#import "GameAlertView.h"
#import "Button.h"
#import "Sounds.h"

@protocol GameDelegate;

@interface GameViewController : UIViewController <DifficultyDelegate>{
    
}

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int currentAnimatingScore;
@property (nonatomic, assign) CGFloat efficiency;

@property (nonatomic, strong) id<GameDelegate> delegate;
@property (nonatomic, assign) CGFloat beltMoveSpeed;
@property (nonatomic, assign) CGFloat animateBeltMoveSpeed;
@property (nonatomic, assign) GameState currentGameState;

@property (strong, nonatomic) TouchImage* pauseButton;
@property (strong, nonatomic) TutorialView* tutorialView;

@property (strong, nonatomic) UIView* pauseView;

@property (strong, nonatomic) NSMutableArray<UIImage*>* sockMainImages;
@property (strong, nonatomic) NSMutableArray<UIImage*>* sockPackages;
@property (strong, nonatomic) NSMutableArray<UIImage*>* sockPackageSizes;
@property (strong, nonatomic) NSMutableArray<UIImage*>* scoreDigitImages;

@property (strong, nonatomic) NSMutableArray<UIImage*>* boxAnimationFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* wheelFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* forkLiftAnimationFrames;
@property (strong, nonatomic) NSMutableArray<UIImage*>* emissionAnimationFrames;

@property (strong, nonatomic) NSMutableArray<UIImage*>* countdownNumbers;

@property (strong, nonatomic) UILabel* scoreLabel;

@property (nonatomic, assign) bool timerPaused;
@property (nonatomic, assign) bool doingTutorial;

-(id)initWithTutorial:(bool)tutorial;
-(void)startGame:(bool)withWarmup;
-(void)gameFrame:(CADisplayLink*)tmr;
-(void)switchGameStateTo:(GameState)newGameState;
-(void)setScoreImages:(int)s;

-(CGFloat)getFinalBeltMoveSpeed:(CGFloat)baseSpeed;

-(void)updateUIBasedOnCurrentGame:(GameData*)game;
-(bool)loadGame:(GameData*)game;
-(void)saveGame;

-(void)generateSock:(bool)twoSocks;

-(void)updateBarForEfficiency:(CGFloat)efficiency;

-(void)animateInExtraUI;
-(void)animateOutExtraUI;

-(void)removeAllSocks;
-(void)animateAllSocksOneScreenLeft:(CGFloat)duration;
@end

@protocol GameDelegate <NSObject>
- (void) switchFromGameToMenu:(GameViewController *)game;
- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score;
- (void) gameEndScore:(int)score;
- (AppState) getAppState;
@end
