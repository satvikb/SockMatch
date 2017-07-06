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
    Small = 0,
    Medium = 1,
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

+ (int)randomNumberBetween:(int)min maxNumber:(int)max;
+ (CGFloat) randFromMin:(CGFloat)min toMax:(CGFloat)max;
+ (CGFloat) propSizeFromSockSize:(SockSize) size;

@end
