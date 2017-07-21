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
    GameData* currentGameData;
    
    UIView* content;
}

@end

@implementation ContainerViewController
@synthesize currentAppState;
@synthesize menuController;
@synthesize gameController;
@synthesize gameOverController;
@synthesize gameCenterEnabled;
@synthesize leaderboardIdentifier;
@synthesize didCompleteTutorial;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self authenticateLocalPlayer];
    
//    [self testFile];
    content = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 2, 1)]];
    [self.view addSubview:content];
    
    didCompleteTutorial = [Storage didCompleteTutorial];
    
    currentAppState = MainMenu;
    
    currentGameData = [GameData sharedGameData];
    
    // Do any additional setup after loading the view.
    gameController = [[GameViewController alloc] initWithTutorial: !didCompleteTutorial];
    gameController.view.layer.zPosition = -100;
    gameController.delegate = self;
    
//    int loadedScore = currentGameData.score;//[Storage getSavedHighScore];
//    gameController.currentAnimatingScore = loadedScore;
//    gameController.score = loadedScore;
//    [gameController setScoreImages:loadedScore];
    [gameController updateUIBasedOnCurrentGame:currentGameData];
    
    gameOverController = [[GameOverViewController alloc] init];
    gameOverController.view.layer.zPosition = 150;
    gameOverController.delegate = self;
    
    int highScore = [Storage getSavedHighScore];
    
    menuController = [[MenuViewController alloc] initWithForkliftAnimation:gameController.forkLiftAnimationFrames andWheel:gameController.wheelFrames sockPackages:gameController.sockPackages boxImage:[gameController.boxAnimationFrames objectAtIndex:gameController.boxAnimationFrames.count-1]];
    menuController.view.layer.zPosition = 100;
    menuController.delegate = self;
    menuController.highScoreLabel.text = [NSString stringWithFormat:@"high score: %i", highScore];
    
    [self displayContentController:gameController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    [self displayContentController:gameOverController withFrame:[self propToRect:CGRectMake(1, 0, 1, 1)]];
    [self displayContentController:menuController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    
    [self startGameLoop];
}

-(void)testFile{
    
    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
                                                                        error:NULL];
    NSLog(@"PATH: %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];
        NSLog(@"File %@.%@", filename, extension);
    }];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"gamedata"];
    NSString *fcontent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"CONTENT:%@", fcontent);
    
//    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSData* data = [NSData dataWithContentsOfFile:filePath];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[data, [NSURL fileURLWithPath:filePath]] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}


- (void) displayContentController: (UIViewController*) contentController withFrame:(CGRect) frame{
    [self addChildViewController:contentController];
    contentController.view.frame = frame;//[self frameForContentController];
    [content addSubview: contentController.view];
    [contentController didMoveToParentViewController:self];
}

-(void)switchFromMenuToGame:(MenuViewController*) menu{
    currentAppState = TransitioningFromMainMenuToGame;
    
    [menuController.gameTitle removeFromSuperview];
    [content addSubview:menuController.gameTitle];
    
    for(Forklift* f in [menuController.forklifts copy]){
        [f removeFromSuperview];
        [content addSubview:f];
    }
    
    [Flurry logEvent:@"Switch_MenuToGame"];
    
    bool loadingData = false;
    
    if(currentGameData.efficiency > 0 && currentGameData.sockData.count > 0){
        if([gameController loadGame:currentGameData]){
            loadingData = true;
            menuController.gameTitle.frame = CGRectOffset(menuController.gameTitle.frame, [self propX:-1], 0);
        }else{
//            [gameController turnLightsOff];
        }
    }
    
    didCompleteTutorial = [Storage didCompleteTutorial];
    if(!didCompleteTutorial){
        [gameController.tutorialView animateTutorialLabelIn];
    }
    
    [gameController startGame:loadingData == true ? false : true];
    [gameController animateInExtraUI];
    
    [self animateFromViewController:menu toPoint:[self propToRect:CGRectMake(-1, 0, 0, 0)].origin toViewController:gameController toPoint:CGPointZero animationFinished:^{
        NSLog(@"STARTING GAME %@", NSStringFromCGRect(gameController.view.frame));
        
        
    }];
}

-(void) switchFromGameToMenu:(GameViewController *)game{
    currentAppState = TransitioningFromGameToMenu;
    [Flurry logEvent:@"Switch_GameToMenu"];
    
}

- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score {
    currentAppState = TransitioningFromGameOverToGame;
    [Flurry logEvent:@"Switch_GameToGameOver"];
    
    [gameOverController setScore:score];
    
    [UIView animateWithDuration:1 animations:^void{
        CGRect f = content.frame;
        f.origin.x -= [self propX:1];
        content.frame = f;
    } completion:^(BOOL finished){
        currentAppState = GameOver;
        [gameOverController didMoveToParentViewController:self];
//        [game animateOutExtraUI];
    }];
    
//    [gameController animateAllSocksOneScreenLeft:1];
//    [self animateFromViewController:game toPoint:CGPointZero toViewController:gameOverController toPoint:CGPointZero animationFinished:^{
//        currentAppState = GameOver;
//        [game animateOutExtraUI];
//        NSLog(@"Switched from game to game over %@ %@", NSStringFromCGRect(game.view.frame), gameOverController.view.backgroundColor);
//    }];
}

- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver {
    currentAppState = TransitioningFromGameOverToMainMenu;
    [Flurry logEvent:@"Switch_GameOverToMenu"];
    
    menuController.view.frame = [self propToRect:CGRectMake(0, 0, 1, 1)];
    [gameController animateOutExtraUI]; ///todo immediate
    [gameController removeAllSocks];
    
    [UIView animateWithDuration:1 animations:^void{
        CGRect f = content.frame;
        f.origin.x += [self propX:1];
        content.frame = f;
    } completion:^(BOOL finished){
        currentAppState = MainMenu;
        [menuController didMoveToParentViewController:self];
    }];
//    [self animateFromViewController:gameOver toPoint:[self propToRect:CGRectMake(1, 0, 0, 0)].origin toViewController:menuController toPoint:[self propToRect:CGRectMake(0, 0, 0, 0)].origin animationFinished:^{
//        currentAppState = MainMenu;
//        [gameController updateBarForEfficiency:100.0];
//        NSLog(@"transitioned: game over to menu %@", NSStringFromCGRect(gameController.view.frame));
//    }];
}

-(void)animateFromViewController:(UIViewController*)vc toPoint:(CGPoint)point toViewController:(UIViewController*)otherVc toPoint:(CGPoint)otherPoint animationFinished:(void (^)(void)) completion{

    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
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

- (void) gameEndScore:(int)score{
    [self reportGCScore:score];
    [Storage saveHighScore:score];
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
        CGFloat propMoveX = [gameController getFinalBeltMoveSpeed:gameController.animateBeltMoveSpeed];
        CGFloat moveX = [self propX:propMoveX];
        
        menuController.gameTitle.frame = CGRectOffset(menuController.gameTitle.frame, -moveX*delta, 0);
        
        if(menuController.gameTitle.frame.origin.x < -menuController.gameTitle.frame.size.width){
            [menuController.gameTitle removeFromSuperview];
            menuController.gameTitle.frame = menuController.titleFrame;
            [menuController.view addSubview:menuController.gameTitle];
            [Flurry logEvent:@"game" timed:true];
            currentAppState = Game;
            
            //not in tutorial
            if(gameController.currentGameState == WarmingUp){
                gameController.currentGameState = Playing;
                [gameController generateSock];
            }
        }
        
        [menuController handleForkliftAnimation:delta];
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
        GKScore *gkScore = [[GKScore alloc] initWithLeaderboardIdentifier:leaderboardIdentifier];
        gkScore.value = s;
        
        [GKScore reportScores:@[gkScore] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            [Flurry logEvent:@"GameCenterReportScore" withParameters:@{@"score":[NSNumber numberWithInt:s]}];
        }];
    }
}

-(void)gcShowLeaderboard{
    if(gameCenterEnabled){
//        GKLeaderboard* gameLeaderboard = [[GKLeaderboard alloc] init];
//        gameLeaderboard.identifier = leaderboardIdentifier;
//        gameLeaderboard.playerScope = GKLeaderboardPlayerScopeGlobal;
////        gameLeaderboard.ra
//
//        [gameLeaderboard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
//            if(error){
//                NSLog(@"Error retreiving scores %@", error);
//            }else{
//                for(GKScore* score in scores){
//                    NSLog(@"SCORE: %@ %lli", score.player.displayName, score.value);
//                }
//
//                GCLeaderboardViewController* scoreViewController = [[GCLeaderboardViewController alloc] initWithScores: scores];
//                scoreViewController.view.layer.zPosition = 200;
//                scoreViewController.view.frame = [self propToRect:CGRectMake(0, 0, 1, 1)];
//                scoreViewController.delegate = self;
//                [self addChildViewController:scoreViewController];
//                [self.view addSubview:scoreViewController.view];
//                [scoreViewController createScoreCells];
//                [scoreViewController animateIn];
//            }
//        }];
        
        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
        
        gcViewController.gameCenterDelegate = self;
        
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = leaderboardIdentifier;
        
        [self presentViewController:gcViewController animated:YES completion:nil];
    }
}

-(void)dismissLeaderboard:(GCLeaderboardViewController*) vc{
    [vc animateOutWithCompletion:^void{
        NSLog(@"dismiss leaderboard");
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
