//
//  ContainerViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "ContainerViewController.h"
#import "Storage.h"

@interface ContainerViewController () {
    CADisplayLink* gameTimer;
}

@end

@implementation ContainerViewController
@synthesize currentAppState;
@synthesize menuController;
@synthesize gameController;
@synthesize gameOverController;
@synthesize gameCenterEnabled;
@synthesize leaderboardIdentifier;
@synthesize completeTutorial;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self authenticateLocalPlayer];
    completeTutorial = [Storage didCompleteTutorial];
    
    currentAppState = MainMenu;
    
    // Do any additional setup after loading the view.
    gameController = [[GameViewController alloc] initWithTutorial:!completeTutorial];
    gameController.view.layer.zPosition = -100;
    gameController.delegate = self;
    
    int highScore = [Storage getSavedHighScore];
    gameController.currentAnimatingScore = highScore;
    [gameController setScoreImages:highScore];
    
    gameOverController = [[GameOverViewController alloc] init];
    gameOverController.view.layer.zPosition = 150;
    gameOverController.delegate = self;
    
    menuController = [[MenuViewController alloc] initWithForkliftAnimation:gameController.forkLiftAnimationFrames andWheel:gameController.wheelFrames sockPackages:gameController.sockPackages];//[[MenuViewController alloc] init];
    menuController.view.layer.zPosition = 100;
    menuController.delegate = self;
    
    [self displayContentController:gameController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    [self displayContentController:gameOverController withFrame:[self propToRect:CGRectMake(1, 0, 1, 1)]];
    [self displayContentController:menuController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    
    [self startGameLoop];
}

- (void) displayContentController: (UIViewController*) content withFrame:(CGRect) frame{
    [self addChildViewController:content];
    content.view.frame = frame;//[self frameForContentController];
    [self.view addSubview: content.view];
    
    [content didMoveToParentViewController:self];
}

-(void)switchFromMenuToGame:(MenuViewController*) menu{
    currentAppState = TransitioningFromMainMenuToGame;
    
    [menuController.gameTitle removeFromSuperview];
    [self.view addSubview:menuController.gameTitle];
    
    for(Forklift* f in menuController.forklifts){
        [f removeFromSuperview];
        [self.view addSubview:f];
    }
    
    [Flurry logEvent:@"Switch_MenuToGame"];
    
    [self animateFromViewController:menu toPoint:[self propToRect:CGRectMake(-1, 0, 0, 0)].origin toViewController:gameController toPoint:CGPointZero animationFinished:^{
        NSLog(@"STARTING GAME %@", NSStringFromCGRect(gameController.view.frame));
        
        if(!completeTutorial){
            [gameController.tutorialView animateTutorialLabelIn];
        }
        
        [gameController startGame];
    }];
}

- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score {
    currentAppState = TransitioningFromGameOverToGame;
    [Flurry logEvent:@"Switch_GameToGameOver"];
    
    [gameOverController setScore:score];
    [self animateFromViewController:game toPoint:CGPointZero toViewController:gameOverController toPoint:CGPointZero animationFinished:^{
        currentAppState = GameOver;
        NSLog(@"Switched from game to game over %@ %@", NSStringFromCGRect(game.view.frame), gameOverController.view.backgroundColor);
    }];
}

- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver {
    currentAppState = TransitioningFromGameOverToMainMenu;
    [Flurry logEvent:@"Switch_GameOverToMenu"];
    [self animateFromViewController:gameOver toPoint:[self propToRect:CGRectMake(1, 0, 0, 0)].origin toViewController:menuController toPoint:[self propToRect:CGRectMake(0, 0, 0, 0)].origin animationFinished:^{
        currentAppState = MainMenu;
        NSLog(@"transitioned from game over to menu %@", NSStringFromCGRect(gameController.view.frame));
    }];
}

-(void)animateFromViewController:(UIViewController*)vc toPoint:(CGPoint)point toViewController:(UIViewController*)otherVc toPoint:(CGPoint)otherPoint animationFinished:(void (^)(void)) completion{

    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        otherVc.view.frame = CGRectMake(otherPoint.x, otherPoint.y, otherVc.view.frame.size.width, otherVc.view.frame.size.height);
        vc.view.frame = CGRectMake(point.x, point.y, vc.view.frame.size.width, vc.view.frame.size.height);
    } completion:^(BOOL finished){
        [otherVc didMoveToParentViewController:self];
        completion();
    }];
}

-(void)menuGameCenterButton{
    if(currentAppState == MainMenu){
        [self gcShowLeaderboard];
    }
}

-(int)getAppState{
    return currentAppState;
}

-(void)reportGCScore:(int)currentScore {
    if(gameCenterEnabled == true && leaderboardIdentifier.length > 0){
        [self gcReportScore:currentScore];
    }
}

-(void)startGameLoop {
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop:)];
//    if (@available(iOS 10.0, *)) {
//        gameTimer.preferredFramesPerSecond = 60;
//    } else {
//        // Fallback on earlier versions
//        gameTimer.frameInterval = 1;
//    }
    gameTimer.preferredFramesPerSecond = 60;
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)stopGameLoop {
    [gameTimer setPaused:true];
    [gameTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    gameTimer = nil;
}

-(void)gameLoop:(CADisplayLink*)tmr {
    CGFloat delta = tmr.duration;
    
    if(currentAppState == TransitioningFromMainMenuToGame){
        CGFloat propMoveX = gameController.animateBeltMoveSpeed/100.0;
        CGFloat moveX = [self propX:propMoveX];
        
        menuController.gameTitle.frame = CGRectOffset(menuController.gameTitle.frame, -moveX*delta, 0);
        
        if(menuController.gameTitle.frame.origin.x < -menuController.gameTitle.frame.size.width){
            [menuController.gameTitle removeFromSuperview];
            menuController.gameTitle.frame = menuController.titleFrame;
            [menuController.view addSubview:menuController.gameTitle];
            [Flurry logEvent:@"game" timed:true];
            currentAppState = Game;
        }
    }
    
    [menuController gameFrame:tmr];
    [gameController gameFrame:tmr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                gameCenterEnabled = YES;
                [Flurry logEvent:@"GameCenterEnabled"];
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *li, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"_ERROR_%@", [error localizedDescription]);
                    }
                    else{
                        leaderboardIdentifier = li;
                    }
                }];
            }
            
            else{
                gameCenterEnabled = NO;
            }
        }
    };
}

-(void)gcReportScore:(int)s{
    if(gameCenterEnabled == true && leaderboardIdentifier.length > 0){
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
        score.value = s;
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            [Flurry logEvent:@"GameCenterReportScore" withParameters:@{@"score":[NSNumber numberWithInt:s]}];
        }];
    }
}

-(void)gcShowLeaderboard{
    if(gameCenterEnabled){
        GKLeaderboard* gameLeaderboard = [[GKLeaderboard alloc] init];
        gameLeaderboard.identifier = leaderboardIdentifier;
        gameLeaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
//        gameLeaderboard.ra
        
        [gameLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
            if(error){
                NSLog(@"Error retreiving scores %@", error);
            }else{
                for(GKScore* score in scores){
                    NSLog(@"SCORE: %@ %lli", score.player.displayName, score.value);
                }
                
                GCLeaderboardViewController* scoreViewController = [[GCLeaderboardViewController alloc] initWithScores: scores];
                scoreViewController.view.layer.zPosition = 200;
                scoreViewController.view.frame = [self propToRect:CGRectMake(0, 0, 1, 1)];
                scoreViewController.delegate = self;
                [self addChildViewController:scoreViewController];
                [self.view addSubview:scoreViewController.view];
                [scoreViewController createScoreCells];
                [scoreViewController animateIn];
            }
        }];
        
//        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
//        
//        gcViewController.gameCenterDelegate = self;
//        
//        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
//        gcViewController.leaderboardIdentifier = leaderboardIdentifier;
//        
//        [self presentViewController:gcViewController animated:YES completion:nil];
    }
}

-(void)dismissLeaderboard:(GCLeaderboardViewController*) vc{
    NSLog(@"dismiss leaderboard");
    [vc animateOutWithCompletion:^void{
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }];
}


-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
