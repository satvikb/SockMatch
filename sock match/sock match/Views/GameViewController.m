//
//  GameViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameViewController.h"
#import "Functions.h"
#import "Flurry.h"
#import "Storage.h"

#define SOCK_HIGHEST_LAYER (50)

@interface GameViewController () {
    CGFloat generateSockTimer;
    
    CGFloat sockMatchThreshold;
    
    NSMutableArray <Sock*>* socks;
    NSMutableArray <Sock*>* socksBeingAnimatedIntoBox;
    
    CGRect conveyorBeltRect;
    NSMutableArray <UIImageView*>* conveyorBeltTiles;
    NSMutableArray <UIImageView*>* bottomConveyorBeltWheels;
    NSMutableArray <NSNumber*>* bottomConveyorBeltWheelsFrames;
    NSMutableArray <UIImageView*>* topConveyorBeltWheels;
    NSMutableArray <NSNumber*>* topConveyorBeltWheelsFrames;
    
    NSMutableArray <UIImageView*>* scoreDigits;
    UILabel* scoreLabel;
    
    CGFloat timeToAnimateScoreValue;
    CGFloat animateScoreValueTimer;
    
    CGFloat _beltImagesSideExtra;
    
    CGFloat animateWheelSpeed;
    CGFloat timeToAnimateWheels;
    CGFloat animateWheelTimer;
    
    CGFloat timeForClawAnimation;
    CGFloat clawAnimationTimer;
    NSMutableArray <Claw*>* claws;
    UIImage* clawMiddleImage;
    UIImage* clawTopImage;
    UIImage* clawBottomImage;
    
    CGFloat timeForForkliftAnimation;
    CGFloat forkliftAnimationTimer;
    NSMutableArray <Forklift*>* forklifts;
    
    CGFloat saveGameTimer;
    CGFloat saveGameInterval;
    
    CGFloat animateBoxTimer;
    CGFloat animateBoxInterval;
    
    EfficiencyBar* bar;
    UIImage* efficiencyBarFrame;
    UIImage* efficiencyBarInner;
    
    UILabel* text_factoryEfficiency;
    UILabel* text_score;
    
    DifficultyCurve* difficultyCurve;
    
    bool animatingInPauseView;
}

@end

@implementation GameViewController

@synthesize score;
@synthesize currentAnimatingScore;
@synthesize efficiency;

@synthesize sockMainImages;
@synthesize sockPackages;
@synthesize sockPackageSizes;
@synthesize scoreDigitImages;

@synthesize boxAnimationFrames;
@synthesize wheelFrames;
@synthesize clawAnimationFrames;
@synthesize forkLiftAnimationFrames;
@synthesize emissionAnimationFrames;

@synthesize countdownNumbers;
@synthesize countdownDetails;

@synthesize beltMoveSpeed;
@synthesize animateBeltMoveSpeed;
@synthesize currentGameState;

@synthesize pauseButton;
@synthesize tutorialView;
@synthesize doingTutorial;
@synthesize timerPaused;
@synthesize pauseView;

-(id)initWithTutorial:(bool)tutorial{
    self = [super init];
    
    timerPaused = false;
    [self loadBufferImages];
    [self setupArrays];
    [self setupGameValues:true];
    if(tutorial == true){
        tutorialView = [[TutorialView alloc] initWithScreenFrame:self.view.frame andSockImage:[sockMainImages objectAtIndex:0]];
        tutorialView.layer.zPosition = 110;
        
        
        __unsafe_unretained typeof(self) ws = self;
        
        [tutorialView setAnimateSockOneCompleteBlock:^(Sock* s){
            timerPaused = true;
        }];
        
        [tutorialView setSockOneTouchEndBlock:^(Sock* s){
            bool onBelt = CGRectContainsPoint(ws->conveyorBeltRect, CGPointMake(CGRectGetMidX([ws.tutorialView.sockOne getCoreRect]), CGRectGetMidY([ws.tutorialView.sockOne getCoreRect])));
            
            if(ws.tutorialView.tutorialState <= 3){
                if(!onBelt){
                    timerPaused = false;
                    [ws.tutorialView animateSockTwoToX:[ws propX:0.5] withBeltMoveSpeed:beltMoveSpeed/100.0];
                    ws.tutorialView.sockOne.allowMovement = false;
                }
            }
        }];
        
        [tutorialView setAnimateSockTwoCompleteBlock:^(Sock* s){
            timerPaused = true;
            ws.tutorialView.sockOne.allowMovement = true;
        }];
        
        [tutorialView setSockTwoTouchMoveBlock:^(Sock* s){
            if([self socksFormPairWith:tutorialView.sockOne andOther:tutorialView.sockTwo] == true){
                timerPaused = false;
                
                [ws madePairBetweenMainSock:ws.tutorialView.sockOne andOtherSock:ws.tutorialView.sockTwo];
                [ws hideTutLabel];
                
                UILabel* efficiencyInfo = [[UILabel alloc] initWithFrame:[ws propToRect:CGRectMake(0.01, 0.15, 0.65, 0.25)]];
                efficiencyInfo.text = @"this is the efficiency of the factory.\nletting socks pass or building up socks reduces the efficiency.\n when efficiency reaches 0, you lose.";
                efficiencyInfo.textAlignment = NSTextAlignmentCenter;
                efficiencyInfo.numberOfLines = 0;
                efficiencyInfo.layer.borderWidth = 2;
                efficiencyInfo.textColor = [UIColor whiteColor];
                
                
                UILabel* tapToContinue = [[UILabel alloc] initWithFrame:[ws propToRect:CGRectMake(0.25, 0.5, 0.5, 0.1)]];
                tapToContinue.text = @"tap to continue.";
                tapToContinue.textAlignment = NSTextAlignmentCenter;
                tapToContinue.textColor = [UIColor whiteColor];
                
                [ws.tutorialView focusOnRect:[ws propToRect:CGRectMake(0.125, 0.03, 0.45, 0.1)] withLabels:@[efficiencyInfo, tapToContinue] touchBlock:^void{
                    timerPaused = false;
                    ws.tutorialView.tutorialState = Completed;
                    ws.tutorialView.tutorialText.text = @"you can also match socks directly on the belt";
                    currentGameState = Playing;
                    [Flurry endTimedEvent:@"tutorial" withParameters:nil];
                    //TODO uncomment for final
                    //                [Storage completeTutorial];
                    [ws performSelector:@selector(hideTutLabel) withObject:nil afterDelay:5];
                }];
            }
        }];
        
        [self.view addSubview:tutorialView];
        doingTutorial = true;
        [Flurry logEvent:@"tutorial" timed:true];
    }
    
    return self;
}

-(void)hideTutLabel{[tutorialView animateTutorialLabelOut];}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"GAME VIEW");
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
    [self createBeltAndWheels];
}

-(void)loadBufferImages {
    boxAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_box"] withYRow:5 withXColumn:4 maxFrames:0];
    clawAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_claw"] withYRow:1 withXColumn:1 maxFrames:0];
    wheelFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_wheels"] withYRow:1 withXColumn:4 maxFrames:0];
    sockPackages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockPackage"] withYRow:5 withXColumn:5 maxFrames:5];
    sockPackageSizes = [self getSplitImagesFromImage:[UIImage imageNamed:@"packageSizes"] withYRow:1 withXColumn:3 maxFrames:0];
    sockMainImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockMain"] withYRow:5 withXColumn:5 maxFrames:5];
    forkLiftAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"forklift"] withYRow:3 withXColumn:1 maxFrames:2];
    emissionAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"emissions"] withYRow:5 withXColumn:1 maxFrames:0];
    scoreDigitImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"numbers"] withYRow:1 withXColumn:10 maxFrames:0];
    
    countdownNumbers = [self getSplitImagesFromImage:[UIImage imageNamed:@"countdownNumbers"] withYRow:1 withXColumn:3 maxFrames:0];
    countdownDetails = [self getSplitImagesFromImage:[UIImage imageNamed:@"countdownDetails"] withYRow:2 withXColumn:2 maxFrames:0];
    
    
    
    clawMiddleImage = [UIImage imageNamed:@"clawMiddle"];
    clawTopImage = [UIImage imageNamed:@"clawTop"];
    clawBottomImage = [UIImage imageNamed:@"clawBottom"];
}

-(void)removeAllSocks{
    for (Sock* sock in socks) {
        [sock removeFromSuperview];
    }
}

-(void)disableSockMovement {
    for (Sock* sock in socks) {
        sock.allowMovement = false;
        //        sock.validSock = false;
    }
}

-(void)enableSockMovement {
    for (Sock* sock in socks) {
        sock.allowMovement = true;
        //        sock.validSock = false;
    }
}


-(void)setupGameValues:(bool)withWarmup {
    currentGameState = NotPlaying;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.055];
    
    if(withWarmup == true){
        difficultyCurve = [[DifficultyCurve alloc] init];
        
        score = 0;
        efficiency = 100.0;
        [self forceSetScore:score];
        [self updateBarForEfficiency:efficiency];
        beltMoveSpeed = 25.0;
        animateBeltMoveSpeed = 0;
        
        animateWheelSpeed = 1;
        timeToAnimateWheels = 0.036;
        animateWheelTimer = 0;
    }else{
        
        beltMoveSpeed = 25.0;
        animateBeltMoveSpeed = beltMoveSpeed;
        
        timeToAnimateWheels = 0.036;
        animateWheelSpeed = timeToAnimateWheels;
        animateWheelTimer = 0;
    }
    
    difficultyCurve.delegate = self;

    timeForClawAnimation = 0.05;
    clawAnimationTimer = 0;
    
    timeForForkliftAnimation = 0.25;
    forkliftAnimationTimer = 0;
    
    timeToAnimateScoreValue = 0.04;
    animateScoreValueTimer = 0;
    
    saveGameTimer = 0;
    saveGameInterval = 20;
    
    animateBoxTimer = 0;
    animateBoxInterval = 0.005;
}

-(void)setupArrays{
    socks = [[NSMutableArray alloc] init];
    claws = [[NSMutableArray alloc] init];
    forklifts = [[NSMutableArray alloc] init];
    socksBeingAnimatedIntoBox = [[NSMutableArray alloc] init];
}

-(void)createUI {
    
    conveyorBeltRect = [self propToRect:CGRectMake(-0.25, 0.15, 1.5, 0.3)];
    
    UIView* topBackground = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 1, 0.15)]];
    topBackground.backgroundColor = [UIColor colorWithRed:(140.0/255.0) green:(174.0/255.0) blue:(0.0/255.0) alpha:1];
    topBackground.layer.zPosition = -5;
    [self.view addSubview:topBackground];
    
//    scoreDigits = [[NSMutableArray alloc] init];
//    [self sizeDigits:4];
    
    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.65, 0.0725, 0.325, 0.05)]];
    scoreLabel.text = @"0";
    scoreLabel.textAlignment = NSTextAlignmentRight;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.font = [UIFont systemFontOfSize:25];
    [self.view addSubview:scoreLabel];
    
    efficiencyBarFrame = [UIImage imageNamed:@"efficiencybar_frame"];
    efficiencyBarInner = [UIImage imageNamed:@"efficiencybar_inner"];
    
    bar = [[EfficiencyBar alloc] initWithFrame:[self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.05)] frameImage:efficiencyBarFrame innerImage:efficiencyBarInner];
    bar.layer.zPosition = 100;
    [self.view addSubview:bar];
    
    text_factoryEfficiency = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.0375)]];
//    text_factoryEfficiency.layer.borderWidth = 2;
    text_factoryEfficiency.text = @"factory efficiency";
    text_factoryEfficiency.layer.zPosition = 101;
    text_factoryEfficiency.textColor = [UIColor whiteColor];
    text_factoryEfficiency.adjustsFontSizeToFitWidth = true;
    text_factoryEfficiency.font = [UIFont systemFontOfSize:25];
    [self.view addSubview:text_factoryEfficiency];
    
    text_score = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.825, 0.035, 0.15, 0.0375)]];
    text_score.text = @"score";
    text_score.layer.zPosition = 102;
    text_score.textAlignment = NSTextAlignmentRight;
    text_score.textColor = [UIColor whiteColor];
    text_score.font = [UIFont systemFontOfSize:20];
    
    [self.view addSubview:text_score];
    
//    pauseButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.25, 0.8, 0.4, 0.1)] withText:@"p" withBlock:^void{
//        NSLog(@"fasdffsdfadf");
//    }];
    
    __unsafe_unretained typeof(self) ws = self;
    pauseButton = [[TouchImage alloc] initWithFrame:[self propToRect:CGRectMake(-0.1, 0.0325, 0.1, 0.075)] image:[UIImage imageNamed:@"pause"]];
//    pauseButton.layer.borderWidth = 2;
    pauseButton.layer.zPosition = 105;
    [pauseButton setBlock:^void{
        NSLog(@"pause");
        
        //TODO  maybe just do currentGameState == Playing;
        if(currentGameState == Playing){//!= WarmingUp && currentGameState != Tutorial && currentGameState != Paused){
            [ws showPauseView];
        }
    }];
    
    [self.view addSubview:pauseButton];
    
    
    
    pauseView = [[UIView alloc] initWithFrame:self.view.frame];
    pauseView.layer.opacity = 0;
    pauseView.layer.zPosition = 110;
    pauseView.backgroundColor = [UIColor blackColor];
    
    UILabel* pauseViewPauseText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.25, 0.5, 0.1)]];
    pauseViewPauseText.text = @"paused";
    pauseViewPauseText.textColor = [UIColor whiteColor];
    pauseViewPauseText.layer.zPosition = 111;
    pauseViewPauseText.textAlignment = NSTextAlignmentCenter;
    pauseViewPauseText.font = [UIFont systemFontOfSize:40];
    pauseViewPauseText.adjustsFontSizeToFitWidth = true;
    [pauseView addSubview:pauseViewPauseText];
    
    UILabel* pauseViewContinueText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.3, 0.35, 0.4, 0.1)]];
    pauseViewContinueText.text = @"tap to continue";
    pauseViewContinueText.textColor = [UIColor whiteColor];
    pauseViewContinueText.layer.zPosition = 112;
    pauseViewContinueText.textAlignment = NSTextAlignmentCenter;
    pauseViewContinueText.font = [UIFont systemFontOfSize:20];
    pauseViewContinueText.adjustsFontSizeToFitWidth = true;
    [pauseView addSubview:pauseViewContinueText];
}

-(void)animateInExtraUI{
    [UIView animateWithDuration:0.5 animations:^void{
        pauseButton.frame = [self propToRect:CGRectMake(0.025, 0.0325, 0.1, 0.075)];
        bar.frame = [self propToRect:CGRectMake(0.15, 0.0725, 0.4, 0.05)];
        text_factoryEfficiency.frame = [self propToRect:CGRectMake(0.15, 0.03, 0.4, 0.0375)];
    }];
}

-(void)animateOutExtraUI{
    [UIView animateWithDuration:0.5 animations:^void{
        pauseButton.frame = [self propToRect:CGRectMake(-0.1, 0.0325, 0.1, 0.075)];
        bar.frame = [self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.05)];
        text_factoryEfficiency.frame = [self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.0375)];
    }];
}

-(void)showPauseView{
    if(!animatingInPauseView){
        [self.view addSubview:pauseView];
        currentGameState = Paused; //todo use functino to switch
        timerPaused = true;
        [UIView animateWithDuration:0.5 animations:^void{
            pauseView.layer.opacity = 0.75;
        } completion:^(BOOL completed){
            animatingInPauseView = false;
            
        }];
        animatingInPauseView = true;
    }
}

-(void)hidePauseView{
    if(!animatingInPauseView){
        [UIView animateWithDuration:0.5 animations:^void{
            pauseView.layer.opacity = 0;
        } completion:^(BOOL completed){
            [pauseView removeFromSuperview];
            [self createCountdown:^{
                currentGameState = Playing; //todo use function to switch
                timerPaused = false;
                animatingInPauseView = false;
            }];
        }];
    }
}

-(void)createCountdown:(void (^)(void)) completion{
    Countdown* testCD = [[Countdown alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.475, 1, 0.1)] numberImages:countdownNumbers detailAnimationImages:countdownDetails];
    
    __unsafe_unretained typeof(Countdown*) weak = testCD;
    
    [testCD setAnimationCompleteBlock:^(BOOL success){
        completion();
        [weak animateOut];
    }];
    [self.view addSubview:testCD];
}

-(void)sizeDigits:(int)numberOfDigits{
    if(scoreDigits.count < numberOfDigits){
        //create more digits
        while (scoreDigits.count < numberOfDigits) {
            UIImageView* scoreDig = [[UIImageView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 0, 0)]];
            scoreDig.contentMode = UIViewContentModeScaleAspectFit;
            scoreDig.layer.magnificationFilter = kCAFilterNearest;
            //                        scoreDig.layer.borderWidth = 2;
            //                        scoreDig.layer.borderColor = [UIColor grayColor].CGColor;
            [scoreDigits addObject:scoreDig];
            [self.view addSubview:scoreDig];
        }
    }else if(scoreDigits.count > numberOfDigits){
        //remove digits
        UIImageView* remove = [scoreDigits objectAtIndex:0];
        [remove removeFromSuperview];
        [scoreDigits removeObject:remove];
    }
    //now resize them all
    //        CGFloat scoreLeftMostPos = 0.65;//0.545;
    CGPoint scoreRightMostPos = CGPointMake(0.95, 0.035);
    UIImage* img = [scoreDigitImages objectAtIndex:0];
    CGFloat realHeight = [self propY:0.08];
    CGFloat aspect = realHeight/(img.size.height);
    CGSize scoreDigitSize = CGSizeMake(((img.size.width*aspect)/self.view.frame.size.width)/*(scoreRightMostPos.x-scoreLeftMostPos)/(CGFloat)scoreDigits.count*/, 0.08);
    
    for(int i = 0; i < scoreDigits.count; i++){
        CGRect newFrame = [self propToRect:CGRectMake(scoreRightMostPos.x-(scoreDigitSize.width*(i+1)), scoreRightMostPos.y, scoreDigitSize.width, scoreDigitSize.height)];
        UIImageView* scoreDig = [scoreDigits objectAtIndex:i];
        scoreDig.frame = newFrame;
    }
}

-(void)createBeltAndWheels {
    conveyorBeltTiles = [self createConveyorBelt:conveyorBeltRect];
    
    CGRect bottomBeltWheelsRect = [self propToRect:CGRectMake(-0.05, 0.4375, 1, 0.025)];
    bottomConveyorBeltWheels = [[NSMutableArray alloc] init];
    bottomConveyorBeltWheelsFrames = [[NSMutableArray alloc] init];
    
    CGRect topBeltWheelsRect = [self propToRect:CGRectMake(-0.05, 0.1375, 1, 0.025)];
    topConveyorBeltWheels = [[NSMutableArray alloc] init];
    topConveyorBeltWheelsFrames = [[NSMutableArray alloc] init];
    
    [self createConveyorBeltWheels:bottomBeltWheelsRect imageArray:bottomConveyorBeltWheels forArray:bottomConveyorBeltWheelsFrames];
    [self createConveyorBeltWheels:topBeltWheelsRect imageArray:topConveyorBeltWheels forArray:topConveyorBeltWheelsFrames];
}

-(NSMutableArray*) createConveyorBelt:(CGRect)frame {
    NSMutableArray <UIImageView*>* beltTiles = [[NSMutableArray alloc] init];
    
    UIImage* beltTileImage = [UIImage imageNamed:@"belt"];
    CGFloat aspectRatio = frame.size.height / beltTileImage.size.height;
    CGFloat imageWidth = beltTileImage.size.width*aspectRatio;
    
    int numOfBeltTiles = (frame.size.width / imageWidth)*2;
    
    _beltImagesSideExtra = (numOfBeltTiles*imageWidth);;
    
    for(int i = 0; i < numOfBeltTiles; i++){
        UIImageView* beltTile = [[UIImageView alloc] initWithImage:beltTileImage];
        beltTile.frame = CGRectMake(frame.origin.x+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
        beltTile.layer.magnificationFilter = kCAFilterNearest;
        beltTile.tag = i;
        [self.view addSubview:beltTile];
        [beltTiles addObject:beltTile];
    }
    
    return beltTiles;
}


-(void) createConveyorBeltWheels:(CGRect)frame imageArray:(NSMutableArray <UIImageView*>*)beltWheels forArray:(NSMutableArray <NSNumber*>*) framesArray{
    
    UIImage* beltWheelImage = [wheelFrames objectAtIndex:0];
    
    CGFloat aspectRatio = frame.size.height / beltWheelImage.size.height;
    CGFloat imageWidth = beltWheelImage.size.width*aspectRatio;
    
    int numOfWheelTiles = (frame.size.width / imageWidth)+2;
    
    for (NSInteger i = 0; i < numOfWheelTiles; ++i){
        [framesArray addObject:[NSNumber numberWithInt:0]];
    }
    
    for(int i = 0; i < numOfWheelTiles; i++){
        UIImageView* beltWheel = [[UIImageView alloc] initWithImage:beltWheelImage];
        beltWheel.frame = CGRectMake(frame.origin.x+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
        
        beltWheel.layer.magnificationFilter = kCAFilterNearest;
        beltWheel.tag = i;
        beltWheel.layer.zPosition = -2;
        
        NSNumber *x = [NSNumber numberWithInt: i%4];
        [framesArray replaceObjectAtIndex:i withObject:x];
        UIImage* newWheelImage = [wheelFrames objectAtIndex:x.integerValue];
        [beltWheel setImage:newWheelImage];
        
        [framesArray replaceObjectAtIndex:i withObject:x];
        
        [self.view addSubview:beltWheel];
        [beltWheels addObject:beltWheel];
    }
}

-(bool)loadGame:(GameData*)game{
    if(game.efficiency > 0){
        [self forceSetDiffucultyCurve:game.difficultyCurve];
        [self forceSetScore:game.score];
        [self forceSetEfficiency:game.efficiency];
        [self loadSocksFromSockData:game.sockData];
        [self switchGameStateTo:Playing];
        return true;
    }
    return false;
}

-(void)saveGame{
    if(efficiency > 0){
        //seperate so points in progress can be handled
        NSMutableArray<SockData*>* sockData = [self getSockDataToSaveGame];
        [[GameData sharedGameData] saveGameWithScore:self.score efficiency:self.efficiency socks:sockData andDifficulty:difficultyCurve];
    }else if(efficiency <= 0){
        [self forceEndGame];
    }
    //    [[GameData sharedGameData] save:score socks:[self getSockDataToSaveGame]];
}

-(void)forceSetDiffucultyCurve:(DifficultyCurve*)curve{
    difficultyCurve = curve;
}

-(void)forceSetScore:(int)aNewScore {
    self.score = aNewScore;
    self.currentAnimatingScore = self.score;
    [self setScoreImages:self.score];
}

-(void)loadSocksFromSockData:(NSMutableArray<SockData*>*)sockData{
    for(SockData* d in sockData){
        [self createSockAtPos:d.origin sockSize:d.sockSize sockId:d.sockId onBelt:d.onConvayorBelt];
    }
}

-(void)updateUIBasedOnCurrentGame:(GameData*)game{
    [self forceSetScore:game.score];
    [self updateBarForEfficiency:game.efficiency];
}

-(void) gameFrame:(CADisplayLink*)tmr {
    CGFloat delta = tmr.duration;
    
    if (currentGameState != NotPlaying && timerPaused == false) {
        
        [self animateBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self updateSocksOnBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self handleAnimateWheel:delta];
        [self handleClawAnimation: delta];
        [self handleForkliftAnimation:delta];
        [self animateAllSockBoxes:delta];
        
        //TODO remove this system or make it more effiecent
        animateScoreValueTimer += tmr.duration;
        
        if(animateScoreValueTimer >= timeToAnimateScoreValue){
            //            int dd = abs(currentAnimatingScore-score);
            //            int d = dd/4;
            //            int ad = dd/d;
            //            int diff = ad < d ? 1 : ad;
            //            NSLog(@"D %i", diff);
            int diff = 3;
            [self animateScore: diff];
            animateScoreValueTimer = 0;
        }
        
        switch (currentGameState) {
            case NotPlaying: break;
            case WarmingUp:
                animateBeltMoveSpeed += delta*5;
                animateWheelSpeed -= delta/4;
                
                if(animateWheelSpeed <= timeToAnimateWheels){
                    animateWheelSpeed = timeToAnimateWheels;
                }
                
                if(animateBeltMoveSpeed >= beltMoveSpeed){
                    animateBeltMoveSpeed = beltMoveSpeed;
                    if(animateWheelSpeed <= timeToAnimateWheels){
                        
                        if(doingTutorial){
                            if(tutorialView != nil){
                                NSLog(@"animating tutorial");
                                [tutorialView animateSockOneToX:[self propX:0.5] withBeltMoveSpeed:beltMoveSpeed/100.0];
                                [self switchGameStateTo:Tutorial];
                            }
                        }
                    }
                }
                break;
            case Tutorial:
                
                break;
            case Paused:
                
                break;
            case Playing:
                [self handleSaveGameTimer:delta];
                [self handleGenerateSock:delta];
                break;
            case Stopping:
                animateBeltMoveSpeed -= delta*8;
                animateWheelSpeed += delta/4;
                
                if(animateBeltMoveSpeed <= 0){
                    animateBeltMoveSpeed = 0;
                    [self endGameIfPossible];
                }
                break;
        }
    }
}

-(void)handleSaveGameTimer:(CGFloat)delta{
    saveGameTimer += delta;
    if(saveGameTimer > saveGameInterval){
        [self saveGame];
        saveGameTimer = 0;
    }
}

-(void)startGame:(bool)withWarmup{
    [self setupGameValues:withWarmup];
    
    if(withWarmup == true){
        [self switchGameStateTo:WarmingUp];
    }else{
        [self disableSockMovement];
        [self createCountdown:^void{
            [self enableSockMovement];
            [self switchGameStateTo:Playing];
        }];
    }
}

-(void)switchGameStateTo:(GameState)newGameState{
    switch (newGameState) {
        case Playing:
            //self begin game
            
            break;
            
        default:
            break;
    }
    
    currentGameState = newGameState;
}

-(void)endGameIfPossible{
    [self disableSockMovement];
    
    if([self canEndGame]){
        [self forceEndGame];
        [self cleanUpSocksWithClaws];
        [self transitionToGameOver];
        [self switchGameStateTo:NotPlaying];
    }
}

-(void)forceEndGame {
    [[GameData sharedGameData] clearSave];
//    [self updateBarForEfficiency:<#(CGFloat)#>]
    [Flurry endTimedEvent:@"game" withParameters:@{@"score":[NSNumber numberWithInt:score], @"numSocks":[self analyticsNumSocks]}];
    if([self.delegate respondsToSelector:@selector(gameEndScore:)]){
        [self.delegate gameEndScore:score];
    }
}

-(NSMutableArray<SockData*>*)getSockDataToSaveGame{
    NSMutableArray<SockData*>* sockData = [[NSMutableArray alloc] init];
    
    for(Sock* s in socks){
        //TODO confirm conditions for saving sock
        if(s.inAPair == false && s.validSock){
            SockData* data = [[SockData alloc] initWithOrigin:[s getCoreRect].origin id:s.sockId size:s.sockSize onConveyorBelt:s.onConvayorBelt];
            [sockData addObject:data];
        }else if(s.inAPair){
            [self pointForSock:s];
        }
    }
    
    return sockData;
}

-(NSNumber*)analyticsNumSocks{
    int i = 0;
    
    for(Sock* s in socks){
        if(!s.inAPair){
            i++;
        }
    }
    
    return [NSNumber numberWithInt:i];
}
//-(NSDictionary*)analyticsWithSocks{
//
//    NSMutableDictionary<NSNumber*, NSDictionary*>* analytics = [[NSMutableDictionary alloc] init];
////    NSMutableDictionary<NSNumber*, NSDictionary*>
//    int i = 0;
//    for(Sock* sock in socks){
//        if(!sock.inAPair){
//            NSDictionary* data = @{[NSNumber numberWithInt:i] : @{@"sockId":[NSNumber numberWithInt:sock.sockId], @"size":[NSNumber numberWithInt:sock.sockSize], @"position":NSStringFromCGPoint([sock getCoreRect].origin)}};
////            [analytics addObject:data];
//            [analytics addEntriesFromDictionary:data];
//        }
//        i++;
//    }
//    return [analytics copy];
//}

-(void) transitionToGameOver {
    if([self.delegate respondsToSelector:@selector(switchFromGameToGameOver:withScore:)]){
        [self.delegate switchFromGameToGameOver:self withScore:score];
    }
}

-(bool)canEndGame{
    bool gameDone = true;
    
    for(Sock* s in socks){
        if(s.animatingIntoBox == true){
            gameDone = false;
        }
    }
    
    if([self anyClawsAnimating] == true){
        gameDone = false;
    }
    return gameDone;
}

-(void)handleGenerateSock:(CGFloat)delta {
    generateSockTimer += delta;
    
    if(generateSockTimer >= difficultyCurve.timeToGenerateSock){
        if(currentGameState == Playing){
            [self generateSock];
        }
        generateSockTimer = 0;
    }
}

-(void)handleAnimateWheel:(CGFloat)delta {
    animateWheelTimer += delta;
    
    if(animateWheelTimer >= animateWheelSpeed){
        [self animateWheels:bottomConveyorBeltWheels withFrames:bottomConveyorBeltWheelsFrames];
        [self animateWheels:topConveyorBeltWheels withFrames:topConveyorBeltWheelsFrames];
        
        animateWheelTimer = 0;
    }
}

-(void)handleClawAnimation:(CGFloat)delta {
    clawAnimationTimer += delta;
    
    if(clawAnimationTimer >= timeForClawAnimation){
        [self animateAllClaws];
        clawAnimationTimer = 0;
    }
}

-(void)handleForkliftAnimation:(CGFloat)delta {
    forkliftAnimationTimer += delta;
    
    if(forkliftAnimationTimer >= timeForForkliftAnimation){
        [self animateAllForklifts];
        forkliftAnimationTimer = 0;
    }
}

-(bool) anySocksOnConveyorBelt {
    bool anySockOnBelt = false;
    for (Sock* sock in socks) {
        bool onBelt = [self updateWeatherSockOnBelt:sock];
        if(onBelt == true){
            anySockOnBelt = true;
        }
    }
    return anySockOnBelt;
}

-(bool)updateWeatherSockOnBelt:(Sock*)sock {
    bool onBelt = [self _sockRectOnBelt:sock];
    sock.onConvayorBelt = onBelt;
    return onBelt;
}

-(bool)_sockRectOnBelt:(Sock*)s{
    return CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX([s getCoreRect]), CGRectGetMidY([s getCoreRect])));
}

-(bool) anyClawsAnimating {
    bool anyClawsAnimating = false;
    for (Claw* claw in claws) {
        if(claw.currentlyAnimating == true){
            anyClawsAnimating = true;
        }
    }
    return anyClawsAnimating;
}

-(void)animateBeltWithSpeed:(CGFloat)speed delta:(CGFloat)delta {
    for (UIImageView* img in conveyorBeltTiles) {
        CGFloat propMoveX = speed/100.0;
        CGFloat moveX = [self propX:propMoveX];
        CGFloat moveDelta = -moveX*delta;
        
        if(img.frame.origin.x <= -img.frame.size.width*4){
            CGRect f = img.frame;
            CGFloat overflow = img.frame.origin.x - (-img.frame.size.width);
            
            f.origin.x = _beltImagesSideExtra-img.frame.size.width+overflow;
            img.frame = f;
        }
        
        img.frame = CGRectOffset(img.frame, moveDelta, 0);
    }
}

-(void) animateWheels:(NSMutableArray<UIImageView*>*) wheels withFrames: (NSMutableArray<NSNumber*>*) frames{
    for (int i = 0; i < wheels.count; i++) {
        NSNumber *x = [NSNumber numberWithInt: ([frames objectAtIndex:i].intValue+1) % 4];
        [frames replaceObjectAtIndex:i withObject:x];
        UIImage* wheelFrame = [wheelFrames objectAtIndex: x.intValue];
        UIImageView* wheel = [wheels objectAtIndex:i];
        [wheel setImage:wheelFrame];
    }
}

-(void) updateSocksOnBeltWithSpeed:(CGFloat)speed delta:(CGFloat)delta {
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    
    for(int i = 0; i < socks.count; i++){
        Sock* sock = [socks objectAtIndex:i];
        
        if(sock != nil){
            if(sock.onConvayorBelt == true){
                CGFloat propMoveX = speed/100.0;
                CGFloat moveX = [self propX:propMoveX];
                
                if([sock getCoreRect].origin.x < -[sock getCoreRect].size.width){
                    if(!sock.inAPair){
                        [self sockGotPastBelt];
                    }else{
                        [self pointForSock:sock];
                    }
                    
                    sock.onConvayorBelt = false;
                    [discardedItems addIndex:index];
                    
                    [sock removeFromSuperview];
                }
                
                sock.frame = CGRectOffset(sock.frame, -moveX*delta, 0);
                sock.theoreticalFrame = sock.frame;
            }
            
            [self checkPairsWithSock:sock];
        }else{
            //            NSLog(@"NO SOCK WHILE UPDATING BELT");
        }
        
        index++;
    }
    [socks removeObjectsAtIndexes:discardedItems];
}

-(void)sockGotPastBelt {
    [self lostEfficiency:20.0];
}

-(void) gotPoint {
    [difficultyCurve tickDifficulty];
    score += 1;
    [self setScoreImages:score];
}

-(void) animateScore:(int)times {
//    if(currentAnimatingScore != score){
//        for (int i = 0; i < times; i++) {
//            if(currentAnimatingScore != score){
//                currentAnimatingScore = currentAnimatingScore < score ? currentAnimatingScore+1 : currentAnimatingScore-1;
//                [self setScoreImages:currentAnimatingScore];
//            }
//        }
//    }
}

-(void) setScoreImages:(int) s {
    scoreLabel.text = [NSString stringWithFormat:@"%i", s];
}

-(void)lostEfficiency:(CGFloat)efficiencyLost {
    efficiency -= efficiencyLost;
    
    if(efficiency >= 0){
        [self updateBarForEfficiency:efficiency];
    }
    
    if(efficiency <= 0){
        [self switchGameStateTo:Stopping];
    }
}

-(void)forceSetEfficiency:(CGFloat)efficiency{
    self.efficiency = efficiency;
    [self updateBarForEfficiency:self.efficiency];
}

-(void)updateBarForEfficiency:(CGFloat)efficiency{
    [bar setInnerBarPercentage:efficiency/100.0];
}

-(void)removeFromView:(UIView*)view {
    [view removeFromSuperview];
}

-(void) generateSock{
    CGFloat y = [Functions randFromMin:0.15 toMax:0.3];
    
    int sockId = [difficultyCurve getNextSockType];
    SockSize size = [difficultyCurve getNextSockSize];
    
    CGPoint newSockPos = [self propToRect:CGRectMake(1.0, y, 0, 0)].origin;
    //imageName:[NSString stringWithFormat:@"sock%i", sockId]
    [self createSockAtPos:newSockPos sockSize:size sockId:sockId onBelt:true];
    
}

-(void) decreaseSockLayerPositions {
    for (Sock* s in socks) {
        s.layer.zPosition = s.layer.zPosition > 0 ? s.layer.zPosition-1 : 0;
    }
}

-(void) createSockAtPos:(CGPoint)pos sockSize:(SockSize)size sockId:(int) sockId onBelt:(bool) onBelt {
    CGFloat width = [self propX: [Functions propSizeFromSockSize:size]];
    UIImage* sockImage = [sockMainImages objectAtIndex:sockId];
    Sock* newSock = [[Sock alloc] initWithFrame:pos width: width sockSize: size sockId: sockId image: sockImage onBelt:true extraPropTouchSpace:0.75];
    //    newSock.layer.borderWidth = 2;
    //    newSock.layer.borderColor = [UIColor grayColor].CGColor;
    
    [newSock setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            [self decreaseSockLayerPositions];
            s.layer.zPosition = SOCK_HIGHEST_LAYER;
        }
    }];
    
    [newSock setTouchMovedBlock:^void (Sock* s, CGPoint p, CGPoint oldPos) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            // if the top middle of the sock is not in the belt
            //            if([self _sockRectOnBelt:s] == false){//CGRectContainsPoint(conveyorBeltRect, CGPointMake([s getCoreRect].origin.x+[s getCoreRect].size.width/2, [s getCoreRect].origin.y)) == false){
            //                if(CGRectIntersectsRect(newFrame, conveyorBeltRect) == false){
            //                    s.frame = newFrame;
            //                    s.theoreticalFrame = newFrame;
            //                }
            //            }else{
            //                //free movement within the belt
            //                s.frame = newFrame;
            //                s.theoreticalFrame = newFrame;
            //            }
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
        }
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            [self updateWeatherSockOnBelt:s];
        }
        
        if([self handleIntersection:s previousOverlap:false direction:0 recursionCount:0]){
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
                s.frame = s.theoreticalFrame;
                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                [self updateWeatherSockOnBelt:s];
                //                [self checkPairsWithSock:s];
            }];
        }
    }];
    
    NSLog(@"Creating Sock! %@", NSStringFromCGRect([newSock getCoreRect]));
    newSock.theoreticalFrame = newSock.frame;
    [self updateWeatherSockOnBelt:newSock];
    [self.view addSubview:newSock];
    [socks addObject:newSock];
}

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

// TODO improve this
/*
 Dir:
 0 none
 1 top
 2 right
 3 bottom
 4 left
 */
// bool there was overlap
-(bool) handleIntersection:(Sock*)s previousOverlap:(bool)prevOverlap direction:(int)d recursionCount:(int)rc{
    bool overlap = false;
    int dir = d;
    //    NSLog(@"handle intersection");
    for(Sock* ss in socks){
        if(ss != s){
            if(!ss.inAPair){
                CGRect f = [s getCoreTheoreticalRect];//s.theoreticalFrame;
                CGRect r = [ss getCoreRect];//ss.frame;
                if(CGRectIntersectsRect(r, f) && !(ss.sockId == s.sockId)){
                    overlap = true;
                    
                    CGRect resolveRect = CGRectIntersection(f, r);
                    [self createIntersectionRectTest:resolveRect];
                    
                    CGFloat finalWidth = 0;
                    CGFloat finalHeight = 0;
                    
                    if(dir == 0 || rc < 4){
                        //DO NOT TOUCH
                        CGFloat newResolveWidth = resolveRect.origin.x+r.size.width/2 > r.origin.x+r.size.width/2 ? -resolveRect.size.width : resolveRect.size.width;
                        CGFloat newResolveHeight = resolveRect.origin.y+r.size.height/2 > r.origin.y+r.size.height/2 ? -resolveRect.size.height : resolveRect.size.height;
                        finalWidth = MIN(fabs(newResolveWidth), fabs(newResolveHeight)) == fabs(newResolveWidth) ? -newResolveWidth : 0;
                        finalHeight = MIN(fabs(newResolveWidth), fabs(newResolveHeight)) == fabs(newResolveHeight) ? -newResolveHeight : 0;
                        
                        if(finalWidth > 0){
                            NSLog(@"Right");
                            dir = 2;
                        }
                        
                        if(finalHeight > 0){
                            NSLog(@"Down");
                            dir = 3;
                        }
                        
                        if(finalWidth < 0){
                            NSLog(@"Left");
                            dir = 4;
                        }
                        
                        if(finalHeight < 0){
                            NSLog(@"Up");
                            dir = 1;
                        }
                        
                        NSLog(@"R %@ %@", NSStringFromCGRect(resolveRect), NSStringFromCGRect(f));
                    }else if(rc < 8){
                        switch (dir) {
                            case 0:
                                NSLog(@"DIR ZERO, SHOULD NOT BE");
                                break;
                            case 1:
                                finalHeight = -resolveRect.size.height;
                                break;
                            case 2:
                                finalWidth = resolveRect.size.height;
                                break;
                            case 3:
                                finalHeight = resolveRect.size.height;
                                break;
                            case 4:
                                finalWidth = -resolveRect.size.height;
                                break;
                            default:
                                break;
                        }
                    }else if(rc < 12){
                        finalWidth = resolveRect.size.height;
                    }else if(rc < 16){
                        finalHeight = resolveRect.size.height;
                    }else if(rc < 20){
                        finalWidth = -resolveRect.size.height;
                    }else{
                        finalHeight = -resolveRect.size.height;
                    }
                    
                    CGRect newFrame = CGRectMake(f.origin.x+finalWidth, f.origin.y+finalHeight, f.size.width, f.size.height);
                    //                    s.theoreticalFrame = newFrame;
                    [s setTheoreticalRectFromCoreTheoreticalRect:newFrame];
                }
            }
        }
    }
    
    return overlap == true ? [self handleIntersection:s previousOverlap:true direction: dir recursionCount:rc+1] : prevOverlap;
}



-(void) createIntersectionRectTest:(CGRect)frame {
    //    UIView* test = [[UIView alloc] initWithFrame: frame];
    //    test.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:0.6];
    //    test.layer.zPosition = 1000;
    //    [self.view addSubview:test];
    //    [self performSelector:@selector(removeFromView:) withObject:test afterDelay:2];
}

-(void) checkPairsWithSock:(Sock*)sock{
    for(int i = 0; i < socks.count; i++){
        Sock* otherSock = [socks objectAtIndex:i];
        
        //        if(!otherSock.animatingSize && !sock.animatingSize){
        if(otherSock != sock && sock.inAPair == false && otherSock.inAPair == false){
            bool pairFormed = [self socksFormPairWith:sock andOther:otherSock];
            
            if(pairFormed == true){
                [self madePairBetweenMainSock:sock andOtherSock:otherSock];
            }
        }
        //        }
    }
}

-(void) madePairBetweenMainSock:(Sock*)sock andOtherSock:(Sock*)otherSock {
    [sock removeFromSuperview];
    [socks removeObject:sock];
    
    
    otherSock.frame = CGRectOffset(otherSock.frame, (sock.frame.origin.x-otherSock.frame.origin.x)/2, (sock.frame.origin.y-otherSock.frame.origin.y)/2);
    otherSock.theoreticalFrame = otherSock.frame;
    
    otherSock.inAPair = sock.inAPair = true;
    otherSock.mainSockInPair = true;
    
    otherSock.otherSockInPair = sock;
    sock.otherSockInPair = otherSock;
    
    [otherSock.overlayImageView setImage:[boxAnimationFrames objectAtIndex:0]];
    
    otherSock.allowMovement = false;
    otherSock.layer.zPosition = 150;
    [otherSock animateDecreaseCoreScale];
    [socksBeingAnimatedIntoBox addObject:otherSock];
}

-(void) animateAllSockBoxes:(CGFloat)delta {
    //    NSLog(@"animate all socks %li", socksBeingAnimatedIntoBox.count);
    animateBoxTimer += delta;
    
    if(animateBoxTimer >= animateBoxInterval){
        for (Sock* s in socksBeingAnimatedIntoBox) {
            [self animateSock:s];
        }
        animateBoxTimer = 0;
    }
}

-(void) animateAllClaws {
    for (Claw* c in claws) {
        [c animateAnimation];
    }
}

-(void) animateAllForklifts {
    for (Forklift* f in forklifts) {
        [f animateAnimation];
        
        switch (f.currentState) {
            case GoingToSock:
                [f animateWheels];
                break;
            case GoingBack:
                [f animateWheelsBackward];
                break;
            default:
                break;
        }
    }
}

-(void) animateSock:(Sock*)s{
    NSInteger currentFrame = [boxAnimationFrames indexOfObject:s.overlayImageView.image];
    NSInteger nextFrame = currentFrame+1;
    
    [self updateWeatherSockOnBelt:s];
    
    if(nextFrame == boxAnimationFrames.count*0.5){
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
            //            s.coreImageView.frame = CGRectMake(s.frame.origin.x+s.frame.size.width/4, s.frame.origin.y+s.frame.size.height/4, s.frame.size.width/2, s.frame.size.height/2);
            s.coreImageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
        } completion:^(BOOL finished){
            [s.coreImageView setImage:nil];
        }];
    }
    
    if(nextFrame >= boxAnimationFrames.count){
        s.animatingIntoBox = false;
        [socksBeingAnimatedIntoBox removeObject:s];
        
        if(!s.onConvayorBelt){
            //            [self createClaw:s givePoint:true];
            [self createForklift:s givePoint:true];
        }
    }else{
        s.animatingIntoBox = true;
        [s.overlayImageView setImage: [boxAnimationFrames objectAtIndex: nextFrame]];
    }
    
    if(nextFrame > boxAnimationFrames.count*0.75){
        //TODO animate height every frame (increase it until normal height), to flow with tape
        [s.veryTopImageView setImage:[sockPackages objectAtIndex:s.sockId]];
        [s.veryTopImageView2 setImage:[sockPackageSizes objectAtIndex:s.sockSize]];
    }
}

-(void)cleanUpSocksWithClaws {
    for (Sock* s in socks) {
        [self createClaw:s givePoint:false];
    }
}

-(void)createClaw:(Sock*)s givePoint:(BOOL)point{
    //    Claw* claw = [[Claw alloc] initClawWithSock:s animationFrames: clawAnimationFrames];
    Claw* claw = [[Claw alloc] initClawWithSock:s animationFrames:clawAnimationFrames middleImage:clawMiddleImage topImage:clawTopImage bottomImage:clawBottomImage];
    claw.layer.zPosition = 100;//SOCK_HIGHEST_LAYER+1;
    [claws addObject:claw];
    [self.view addSubview:claw];
    
    s.allowMovement = false;
    
    [claw animateWithSpeed:0.5 withCompletion:^void {
//        if(point == true){
//            [self pointForSock:s];
//        }
//
        [s removeFromSuperview];
        [socks removeObject:s];
        
        [claw removeFromSuperview];
        [claws removeObject:claw];
    }];
}

-(void)createForklift:(Sock*)s givePoint:(BOOL)point{
    Forklift* lift = [[Forklift alloc] initWithSock:s forkliftAnimationFrames:forkLiftAnimationFrames wheelAnimationFrames:wheelFrames];
    lift.layer.zPosition = 102;
    [forklifts addObject:lift];
    [self.view addSubview:lift];
    
    [lift animateWithSpeed:1 withCompletion:^void{
        if(point == true){
            [self pointForSock:s];
        }
        
        [s removeFromSuperview];
        [socks removeObject:s];
        
        [lift removeFromSuperview];
        [forklifts removeObject:lift];
    }];
    
}

-(void) pointForSock:(Sock*)s{
    s.allowMovement = false;
    if(s.validSock == true){
        [self gotPoint];
    }
}

-(void)newSockType{
    [self createInfoBanner:3 text:@"new sock type!"];
}

-(void)createInfoBanner:(int)times text:(NSString*)text{
    InfoBanner* banner = [[InfoBanner alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.45, 1, 0.1)] repeatTime:times text:text];
    banner.layer.zPosition = 120;
    [self.view addSubview:banner];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(currentGameState == Paused){
        [self hidePauseView]; // todo prevent mutliple taps (during 0.5 second animation)
    }
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 1.0 );
    
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, newSize.width, newSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(bool) socksFormPairWith:(Sock*)oneSock andOther:(Sock*)otherSock{
    // does not need to use core rect because of position normalization
    CGPoint delta = CGPointMake(otherSock.frame.origin.x-oneSock.frame.origin.x, otherSock.frame.origin.y-oneSock.frame.origin.y);
    
    if(fabs(delta.x) < sockMatchThreshold && fabs(delta.y) < sockMatchThreshold){
        if(oneSock.sockId == otherSock.sockId){
            if(oneSock.sockSize == otherSock.sockSize){
                return true;
            }
        }
    }
    
    return false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray<UIImage*> *)getSplitImagesFromImage:(UIImage *)image withYRow:(NSInteger)rows withXColumn:(NSInteger)columns maxFrames:(int)maxFrames{
    NSMutableArray<UIImage*> *aMutArrImages = [NSMutableArray array];
    CGSize imageSize = image.size;
    CGFloat scale = image.scale;
    
    CGFloat xPos = 0.0, yPos = 0.0;
    CGFloat width = imageSize.width/columns;
    CGFloat height = imageSize.height/rows;
    
    maxFrames = maxFrames == 0 ? width*height : maxFrames;
    
    int frameCounter = 1;
    for (int aIntY = 0; aIntY < rows; aIntY++) {
        xPos = 0.0;
        for (int aIntX = 0; aIntX < columns; aIntX++) {
            if(frameCounter <= maxFrames){
                CGRect rect = CGRectMake(xPos*scale, yPos*scale, width*scale, height*scale);
                
                CGImageRef cImage = CGImageCreateWithImageInRect(image.CGImage,  rect);
                
                UIImage* aImgRef = [UIImage imageWithCGImage:cImage scale:scale orientation:UIImageOrientationUp];
                
                [aMutArrImages addObject:aImgRef];
                xPos += width;
                frameCounter += 1;
            }else{
                return aMutArrImages;
            }
        }
        yPos += height;
    }
    return aMutArrImages;
}

-(CGFloat) propY:(CGFloat) y {
    return y*self.view.frame.size.height;
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
