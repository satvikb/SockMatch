//
//  Functions.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ARC4RANDOM_MAX 0x100000000

@interface Functions : NSObject {}

extern const CGFloat SmallSockPropSize;
extern const CGFloat MediumSockPropSize;
extern const CGFloat LargeSockPropSize;

typedef enum SockSize {
    Small = 1,
    Medium = 0,
    Large = 2
} SockSize;

typedef enum AppState {
    MainMenu = 0,
    TransitioningFromMainMenuToGame = 1,
    Game = 2,
    TransitioningFromGameToGameOver = 4,
    GameOver = 4,
    TransitioningFromGameOverToMainMenu = 3,
    TransitioningFromGameOverToGame = 3
} AppState;

typedef enum GameState {
    NotPlaying = 0,
    WarmingUp = 1,
    Tutorial = 2,
    Paused = 3,
    Playing = 4,
    Stopping = 5
} GameState;

typedef enum TutorialState {
    NoState = 0,
    AnimatingSockOne = 1,
    WaitingToMoveSockOne = 2,
    AnimatingSockTwo = 3,
    WaitingToMoveSockTwo = 4,
    Completed = 5
} TutorialState;

//typedef enum InfoBannerType {
//    AutoStop = 0,
//    Repeating = 1
//} InfoBannerType;

+ (int)randomNumberBetween:(int)min maxNumber:(int)max;
+ (CGFloat) randFromMin:(CGFloat)min toMax:(CGFloat)max;
+ (CGFloat) propSizeFromSockSize:(SockSize) size;

@end



@interface UIView (AnimationsHandler)

- (void)pauseAnimations;
- (void)resumeAnimations;

@end

@implementation UIView (AnimationsHandler)
- (void)pauseAnimations
{
    CFTimeInterval paused_time = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0;
    self.layer.timeOffset = paused_time;
}

- (void)resumeAnimations
{
    CFTimeInterval paused_time = [self.layer timeOffset];
    self.layer.speed = 1.0f;
    self.layer.timeOffset = 0.0f;
    self.layer.beginTime = 0.0f;
    CFTimeInterval time_since_pause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
    self.layer.beginTime = time_since_pause;
}

@end

