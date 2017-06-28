//
//  ContainerViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "MenuViewController.h"
#import "GameViewController.h"
#import "GameOverViewController.h"

@interface ContainerViewController : UIViewController <MenuDelegate, GameDelegate, GameOverDelegate, GKGameCenterControllerDelegate>{
    
}

typedef enum AppState {
    MainMenu = 0,
    TransitioningFromMainMenuToGame = 1,
    Game = 2,
    TransitioningFromGameToGameOver = 4,
    GameOver = 4,
    TransitioningFromGameOverToMainMenu = 3,
    TransitioningFromGameOverToGame = 3
} AppState;

@property (nonatomic, assign) AppState currentAppState;
@property (strong, nonatomic) MenuViewController *menuController;
@property (strong, nonatomic) GameViewController *gameController;
@property (strong, nonatomic) GameOverViewController *gameOverController;

@property (nonatomic, assign) bool gameCenterEnabled;
@property (nonatomic, strong) NSString* leaderboardIdentifier;

- (void) displayContentController: (UIViewController*) content withFrame:(CGRect) frame;
-(void)authenticateLocalPlayer;
-(void)gcReportScore:(int)s;

@end

