//
//  ContainerViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Flurry.h"
#import "MenuViewController.h"
#import "GameViewController.h"
#import "GameOverViewController.h"
#import "GCLeaderboardViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContainerViewController : UIViewController <MenuDelegate, GameDelegate, GameOverDelegate, LeaderboardDelegate, GKGameCenterControllerDelegate, MFMailComposeViewControllerDelegate>{
    
}

@property (nonatomic, assign) AppState currentAppState;
@property (strong, nonatomic) MenuViewController *menuController;
@property (strong, nonatomic) GameViewController *gameController;
@property (strong, nonatomic) GameOverViewController *gameOverController;

@property (nonatomic, assign) bool gameCenterEnabled;
@property (nonatomic, strong) NSString* leaderboardIdentifier;

@property (nonatomic, assign) bool didCompleteTutorial;

- (void) displayContentController: (UIViewController*) content withFrame:(CGRect) frame;
-(void)authenticateLocalPlayer;
-(void)gcReportScore:(int)s;

@end

