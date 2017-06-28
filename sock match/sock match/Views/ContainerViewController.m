//
//  ContainerViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "ContainerViewController.h"

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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self authenticateLocalPlayer];
    
    currentAppState = MainMenu;
    
    // Do any additional setup after loading the view.
    menuController = [[MenuViewController alloc] init];
    menuController.view.layer.zPosition = 100;
    menuController.delegate = self;
    
    gameController = [[GameViewController alloc] init];
    gameController.view.layer.zPosition = -100;
    gameController.delegate = self;
    
    gameOverController = [[GameOverViewController alloc] init];
    gameOverController.view.layer.zPosition = 150;
    gameOverController.delegate = self;
    
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
    
    [self animateFromViewController:menu toPoint:[self propToRect:CGRectMake(-1, 0, 0, 0)].origin toViewController:gameController toPoint:CGPointZero animationFinished:^{
        NSLog(@"STARTING GAME %@", NSStringFromCGRect(gameController.view.frame));
        [gameController startGame];
    }];
}

- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score {
    currentAppState = TransitioningFromGameOverToGame;
    [gameOverController setScore:score];
    [self animateFromViewController:game toPoint:CGPointZero toViewController:gameOverController toPoint:CGPointZero animationFinished:^{
        currentAppState = GameOver;
        NSLog(@"Switced from game to game over %@ %@", NSStringFromCGRect(game.view.frame), gameOverController.view.backgroundColor);
    }];
}

- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver {
    currentAppState = TransitioningFromGameOverToMainMenu;
    [self animateFromViewController:gameOver toPoint:[self propToRect:CGRectMake(1, 0, 0, 0)].origin toViewController:menuController toPoint:[self propToRect:CGRectMake(0, 0, 0, 0)].origin animationFinished:^{
        currentAppState = MainMenu;
        NSLog(@"transitioned from game over to menu %@", NSStringFromCGRect(gameController.view.frame));
    }];
}

-(void)animateFromViewController:(UIViewController*)vc toPoint:(CGPoint)point toViewController:(UIViewController*)otherVc toPoint:(CGPoint)otherPoint animationFinished:(void (^)(void)) completion{

    [UIView animateWithDuration:0.25 animations:^{
        otherVc.view.frame = CGRectMake(otherPoint.x, otherPoint.y, otherVc.view.frame.size.width, otherVc.view.frame.size.height);
        vc.view.frame = CGRectMake(point.x, point.y, vc.view.frame.size.width, vc.view.frame.size.height);
    } completion:^(BOOL finished){
        [otherVc didMoveToParentViewController:self];
        completion();
    }];
}

-(void)menuGameCenterButton{
    NSLog(@"leaderboard %i", currentAppState);
    if(currentAppState == MainMenu){
        [self gcShowLeaderboard];
    }
}

-(void)reportGCScore:(int)currentScore {
    [self gcReportScore:currentScore];
}

-(void)startGameLoop {
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameLoop:)];
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
            currentAppState = Game;
        }
    }
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
    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
    score.value = s;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)gcShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcViewController.leaderboardIdentifier = leaderboardIdentifier;
    
    [self presentViewController:gcViewController animated:YES completion:nil];
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
