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

#define PAUSE_VIEW_TAG (10)
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
    
    NSMutableArray <UIImageView*>* floorViewss;
    
    NSMutableArray <UIImageView*>* scoreDigits;
    
    CGFloat timeToAnimateScoreValue;
    CGFloat animateScoreValueTimer;
    
    CGFloat _beltImagesSideExtra;
    
    CGFloat animateWheelSpeed;
    CGFloat timeToAnimateWheels;
    CGFloat animateWheelTimer;
    
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
    
    CGFloat efficiencyTickTimer;
    CGFloat timeToTickEfficiency;
    
    NSMutableArray <InfoBanner*>* infoBanners;
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
@synthesize forkLiftAnimationFrames;
@synthesize emissionAnimationFrames;

@synthesize countdownNumbers;
@synthesize scoreLabel;

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
        
        [tutorialView setSockOneTouchMoveBlock:^void(Sock* s){
            [ws tutorialViewSockMove:ws.tutorialView];
        }];
            
        [tutorialView setSockOneTouchEndBlock:^(Sock* s){
            bool onBelt = [ws _sockRectOnBelt:ws.tutorialView.sockOne];//CGRectContainsPoint(ws->conveyorBeltRect, CGPointMake(CGRectGetMidX([ws.tutorialView.sockOne getCoreRect]), CGRectGetMidY([ws.tutorialView.sockOne getCoreRect])));
            
            if(ws.tutorialView.tutorialState <= 3){
                if(!onBelt){
                    timerPaused = false;
                    [ws.tutorialView animateSockTwoToX:[ws propX:0.5] withBeltMoveSpeed:[ws getFinalBeltMoveSpeed:ws.beltMoveSpeed]];
                    ws.tutorialView.sockOne.allowMovement = false;
                }
            }
        }];
        
        [tutorialView setAnimateSockTwoCompleteBlock:^(Sock* s){
            timerPaused = true;
            ws.tutorialView.sockOne.allowMovement = true;
        }];
        
        [tutorialView setSockTwoTouchMoveBlock:^(Sock* s){
            [ws tutorialViewSockMove:ws.tutorialView];
        }];
        
        [self.view addSubview:tutorialView];
        doingTutorial = true;
        [Flurry logEvent:@"tutorial" timed:true];
    }
    
    return self;
}

-(void)tutorialViewSockMove:(TutorialView*)tutView{
    __unsafe_unretained typeof(self) ws = self;

    if([self socksFormPairWith:tutView.sockOne andOther:tutView.sockTwo] == true){
        timerPaused = false;
        [socks addObject:ws.tutorialView.sockTwo];
        [ws madePairBetweenMainSock:ws.tutorialView.sockOne andOtherSock:ws.tutorialView.sockTwo];
        
        UILabel* efficiencyInfo1 = [[UILabel alloc] initWithFrame:[ws propToRect:CGRectMake(0.01, 0.15, 0.98, 0.3)]];
        efficiencyInfo1.text = @"this is the efficiency of the factory.";
        efficiencyInfo1.textAlignment = NSTextAlignmentCenter;
        efficiencyInfo1.numberOfLines = 0;
//        efficiencyInfo1.layer.borderWidth = 2;
        efficiencyInfo1.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
        //                efficiencyInfo1.adjustsFontSizeToFitWidth = true;
        efficiencyInfo1.textColor = [UIColor whiteColor];
      
        
        
        
        UILabel* efficiencyInfo2 = [[UILabel alloc] initWithFrame:[ws propToRect:CGRectMake(0.01, 0.15, 0.98, 0.3)]];
        efficiencyInfo2.text = @"letting socks through or building up socks reduces the efficiency.";
        efficiencyInfo2.textAlignment = NSTextAlignmentCenter;
        efficiencyInfo2.numberOfLines = 0;
        //        efficiencyInfo2.layer.borderWidth = 2;
        efficiencyInfo2.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
        //                efficiencyInfo2.adjustsFontSizeToFitWidth = true;
        efficiencyInfo2.textColor = [UIColor whiteColor];
        
        
        
        UILabel* efficiencyInfo3 = [[UILabel alloc] initWithFrame:[ws propToRect:CGRectMake(0.01, 0.15, 0.98, 0.3)]];
        efficiencyInfo3.text = @"when efficiency reaches 0 you lose.";
        efficiencyInfo3.textAlignment = NSTextAlignmentCenter;
        efficiencyInfo3.numberOfLines = 0;
        //        efficiencyInfo3.layer.borderWidth = 2;
        efficiencyInfo3.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
        //                efficiencyInfo3.adjustsFontSizeToFitWidth = true;
        efficiencyInfo3.textColor = [UIColor whiteColor];
        
        
        
        
        [ws.tutorialView focusOnRect:[ws propToRect:CGRectMake(0.13, 0.0225, 0.45, 0.125)] withLabels:@[efficiencyInfo1, efficiencyInfo2, efficiencyInfo3] touchBlock:^void{
            timerPaused = false;
            ws.tutorialView.tutorialState = Completed;
            ws.tutorialView.tutorialText.text = @"you can also match socks directly on the belt";
            currentGameState = Playing;
            [Flurry endTimedEvent:@"tutorial" withParameters:nil];
            //TODO uncomment for final
            [Storage completeTutorial];
            doingTutorial = false;
            [ws performSelector:@selector(hideTutLabel) withObject:nil afterDelay:5];
        }];
    }
}

-(void)hideTutLabel{[tutorialView animateTutorialLabelOutAndRemoveTutorialView];}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"GAME VIEW");
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
    [self createBeltAndWheels];
}

-(void)loadBufferImages {
    boxAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"animBox"] withYRow:5 withXColumn:4 maxFrames:0];
    wheelFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"wheelAnimation"] withYRow:1 withXColumn:4 maxFrames:0];
    sockPackages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockPackage"] withYRow:5 withXColumn:5 maxFrames:18];
    sockPackageSizes = [self getSplitImagesFromImage:[UIImage imageNamed:@"packageSizes"] withYRow:1 withXColumn:3 maxFrames:0];
    sockMainImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockMain.png"] withYRow:5 withXColumn:5 maxFrames:18];
    forkLiftAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"forklift"] withYRow:3 withXColumn:1 maxFrames:2];
    emissionAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"emissions"] withYRow:5 withXColumn:1 maxFrames:0];
    scoreDigitImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"numbers"] withYRow:1 withXColumn:10 maxFrames:0];
    
    countdownNumbers = [self getSplitImagesFromImage:[UIImage imageNamed:@"countdownNumbers"] withYRow:1 withXColumn:3 maxFrames:0];
}

//-(void)removeAllSocks{
//    for (Sock* sock in [socks copy]) {
//        [sock removeFromSuperview];
//    }
//}

-(void)disableSockMovement {
    for (Sock* sock in [socks copy]) {
        sock.allowMovement = false;
        //        sock.validSock = false;
    }
}

-(void)enableSockMovement {
    for (Sock* sock in [socks copy]) {
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

    timeForForkliftAnimation = 0.25;
    forkliftAnimationTimer = 0;
    
    timeToAnimateScoreValue = 0.04;
    animateScoreValueTimer = 0;
    
    saveGameTimer = 0;
    saveGameInterval = 5;
    
    animateBoxTimer = 0;
    animateBoxInterval = 0.005;
    
    efficiencyTickTimer = 0;
    timeToTickEfficiency = 1;
}

-(void)setupArrays{
    socks = [[NSMutableArray alloc] init];
    forklifts = [[NSMutableArray alloc] init];
    socksBeingAnimatedIntoBox = [[NSMutableArray alloc] init];
    infoBanners = [[NSMutableArray alloc] init];
}

-(void)createUI {
    
    conveyorBeltRect = [self propToRect:CGRectMake(-0.25, 0.15, 1.5, 0.3)];
    
//    UIView* cbeltrect = [[UIView alloc] initWithFrame:conveyorBeltRect];
//    cbeltrect.layer.borderWidth = 4;
//    cbeltrect.layer.borderColor = UIColor.blueColor.CGColor;
//    cbeltrect.layer.zPosition = 1000;
//    [self.view addSubview:cbeltrect];
    
    UIView* topBackground = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, 0, 3, 0.15)]];
    topBackground.backgroundColor = [UIColor colorWithRed:(66/255.0) green:(134/255.0) blue:(244/255.0) alpha:0.4];//[UIColor colorWithRed:(140.0/255.0) green:(174.0/255.0) blue:(0.0/255.0) alpha:1];
    topBackground.layer.zPosition = -5;
    [self.view addSubview:topBackground];
    
    UIView* factoryFloor = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, 0, 3, 1)]];
    factoryFloor.backgroundColor = [UIColor whiteColor];
    factoryFloor.layer.zPosition = -10;
    [self.view addSubview:factoryFloor];
    
    
    
//    scoreDigits = [[NSMutableArray alloc] init];
//    [self sizeDigits:4];
    
    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.65, 0.0625, 0.325, 0.05)]];
    scoreLabel.text = @"0";
    scoreLabel.textAlignment = NSTextAlignmentRight;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
    [self.view addSubview:scoreLabel];
    
    efficiencyBarFrame = [UIImage imageNamed:@"UIFrame"];
    efficiencyBarInner = [UIImage imageNamed:@"UIInnerUp"];
    
    bar = [[EfficiencyBar alloc] initWithFrame:[self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.05)] frameImage:efficiencyBarFrame innerImage:efficiencyBarInner];
    bar.layer.zPosition = 100;
    bar.tag = 13;
    [self.view addSubview:bar];
    
    text_factoryEfficiency = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.15, -0.05, 0.4, 0.04)]];
//    text_factoryEfficiency.layer.borderWidth = 2;
    [text_factoryEfficiency setFrame:CGRectIntegral(text_factoryEfficiency.frame)];

    text_factoryEfficiency.text = @"Factory Efficiency";
    text_factoryEfficiency.layer.zPosition = 101;
//    text_factoryEfficiency.layer.borderWidth = 1;
    text_factoryEfficiency.tag = 12;
//    text_factoryEfficiency.layer.shouldRasterize = true;
//    text_factoryEfficiency.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    text_factoryEfficiency.textColor = [UIColor whiteColor];
//    text_factoryEfficiency.minimumScaleFactor = 0.5;
    text_factoryEfficiency.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    text_factoryEfficiency.adjustsFontSizeToFitWidth = true;

    [self.view addSubview:text_factoryEfficiency];
    
    text_score = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.825, 0.025, 0.15, 0.0375)]];
    text_score.text = @"score";
    text_score.layer.zPosition = 102;
//    text_score.layer.borderWidth = 1;
    text_score.textAlignment = NSTextAlignmentRight;
    text_score.textColor = [UIColor whiteColor];
    text_score.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:23]];
    
    [self.view addSubview:text_score];
    
    
//    CGRect screen = [self propToRect:CGRectMake(0, 0, 1, 1)];
//    CGFloat beltAndTopSize = conveyorBeltRect.origin.y+conveyorBeltRect.size.height;
//    UIView* test = [[UIView alloc] initWithFrame: CGRectMake(screen.origin.x, screen.origin.y+beltAndTopSize, screen.size.width, screen.size.height-beltAndTopSize)];
//    test.layer.borderWidth = 3;
//    test.layer.zPosition = 1000;
//    test.layer.borderColor = UIColor.blueColor.CGColor;
//    [self.view addSubview:test];
    
    UIView* floorImages = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(-1, 0.25, 3, 0.85)]];
    floorImages.layer.zPosition = -10;
//    [self.view addSubview:floorImages];
    
    UIImage* floorImg = [UIImage imageNamed:@"floor"];
    CGFloat curX = -0.025;
    CGFloat curY = -0.05;
    
    CGFloat pw = 0.1;
    CGFloat width = [self propX:pw];
    CGFloat propHeight = width/[self propY:1];
    
    for(int y = 0; y < (floorImages.frame.size.height/width); y++){
        for(int x = 0; x < (floorImages.frame.size.width/width); x++){
            if(x % 1 == 0 && y % 1 == 0){
                CGFloat x = [self propX:y % 2 == 0 ? curX : curX+0.05];
                CGFloat y = [self propY:curY];
                UIImageView* floor = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                floor.layer.magnificationFilter = kCAFilterNearest;
                floor.contentMode = UIViewContentModeScaleAspectFit;
                floor.transform = CGAffineTransformMakeRotation(0.7853981634);
//                            floor.layer.borderWidth = 1;
                floor.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
                floor.layer.zPosition = -10;
                [floor setImage: floorImg];
                [floorImages addSubview:floor];
            }
            curX += pw+0.01;
        }
        curY += propHeight+0.01;
        curX = 0;
    }
    
    
//    pauseButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.25, 0.8, 0.4, 0.1)] withText:@"p" withBlock:^void{
//        NSLog(@"fasdffsdfadf");
//    }];
    
    __unsafe_unretained typeof(self) ws = self;
    pauseButton = [[TouchImage alloc] initWithFrame:[self propToRect:CGRectMake(0.025, -0.075, 0.1, 0.075)] image:[UIImage imageNamed:@"pause"]];
//    pauseButton.layer.borderWidth = 2;
    pauseButton.layer.zPosition = 150;
    pauseButton.tag = 11;
    [pauseButton setBlock:^void{
        NSLog(@"pause");
        
        [ws pauseGame];
    }];
    
    [self.view addSubview:pauseButton];
    
    
    
    pauseView = [[UIView alloc] initWithFrame:self.view.frame];
    pauseView.layer.opacity = 0;
    pauseView.layer.zPosition = 500;
    pauseView.tag = PAUSE_VIEW_TAG;
    pauseView.backgroundColor = [UIColor blackColor];
    
    UILabel* pauseViewPauseText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.25, 0.5, 0.1)]];
    pauseViewPauseText.text = @"paused";
    pauseViewPauseText.textColor = [UIColor whiteColor];
    pauseViewPauseText.layer.zPosition = 111;
    pauseViewPauseText.textAlignment = NSTextAlignmentCenter;
    pauseViewPauseText.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:40]];
    pauseViewPauseText.adjustsFontSizeToFitWidth = true;
    [pauseView addSubview:pauseViewPauseText];
    
    UILabel* pauseViewContinueText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.3, 0.35, 0.4, 0.1)]];
    pauseViewContinueText.text = @"tap to continue";
    pauseViewContinueText.textColor = [UIColor whiteColor];
    pauseViewContinueText.layer.zPosition = 112;
    pauseViewContinueText.textAlignment = NSTextAlignmentCenter;
    pauseViewContinueText.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    pauseViewContinueText.adjustsFontSizeToFitWidth = true;
    [pauseView addSubview:pauseViewContinueText];
    
//    UIImage* playImage = [UIImage imageNamed:@"UIFrame"];
//    UIImage* playImageDown = [UIImage imageNamed:@"playPressed"];
//    playImage = [self image:playImage WithTint:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
//    playImageDown = [self image:playImageDown WithTint:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
//    Button* playButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.1)] withText:@"play" withBlock:^void{
////        [self pressPlayButton:playButton];
//    }];
//    //    playButton.layer.borderWidth = 3;
//    playButton.layer.zPosition = 103;
//    [self.view addSubview:playButton];
    
    
//    [self createInfoBanner:0 text:@"test should pause"];
//    [self newSockSize];
}

-(void)pauseGame{
    //TODO  maybe just do currentGameState == Playing;
    if(currentGameState == Playing){//!= WarmingUp && currentGameState != Tutorial && currentGameState != Paused){
        [[Sounds sharedInstance] playSoundEffect:PauseUnpause loops:0];
        [self saveGame];
        
        for(Sock* s in [self->socks copy]){
            [s animateDecreaseCoreScale];
            s.touchEndedBlock(s, CGPointZero);
        }
        [self disableSockMovement];
        [self showPauseView];
    }
}

- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor{
    UIGraphicsBeginImageContextWithOptions (image.size, NO, image.scale); // for correct resolution on retina, thanks @MobileVet
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // image drawing code here
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // tint image (loosing alpha) - the luminosity of the original image is preserved
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, image.CGImage);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

-(void)pressPlayButton:(id)sender{
    //    id<MenuTransition> strongDelegate = self.delegate;
    
    if([self.delegate respondsToSelector:@selector(switchFromGameToMenu:)]){
        [self.delegate switchFromGameToMenu:self];
    }
}

-(void)animateInExtraUI{
    [UIView animateWithDuration:0.25 animations:^void{
        pauseButton.frame = [self propToRect:CGRectMake(0.025, 0.025, 0.1, 0.075)];
        bar.frame = [self propToRect:CGRectMake(0.15, 0.0625, 0.4, 0.05)];
        text_factoryEfficiency.frame = [self propToRect:CGRectMake(0.15, 0.015, 0.4, 0.04)];
    }];
}

-(void)animateOutExtraUI{
    [UIView animateWithDuration:0.25 animations:^void{
        pauseButton.frame = [self propToRect:CGRectMake(0.025, -0.075, 0.1, 0.075)];
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
            [self pauseAllSubviewAnimations];
        }];
        animatingInPauseView = true;
    }
}

-(void)hidePauseView{
    if(!animatingInPauseView){
        [[Sounds sharedInstance] playSoundEffect:PauseUnpause loops:0];
        [UIView animateWithDuration:0.5 animations:^void{
            pauseView.layer.opacity = 0;
        } completion:^(BOOL completed){
            [pauseView removeFromSuperview];
            [self disableSockMovement];
            [self createCountdown:^{
                [self enableSockMovement];
                currentGameState = Playing; //todo use function to switch
                timerPaused = false;
                animatingInPauseView = false;
                [self resumeAllSubviewAnimations];
            }];
        }];
        animatingInPauseView = true;
    }
}

-(void)pauseAllSubviewAnimations{
    for(UIView* view in self.view.subviews){
        //todo
        if(view.tag != PAUSE_VIEW_TAG && view.tag != 11 && view.tag != 12 && view.tag != 13){
            [view pauseAnimations];
        }
    }
}

-(void)resumeAllSubviewAnimations{
    for(UIView* view in self.view.subviews){
        if(view.tag != PAUSE_VIEW_TAG && view.tag != 11 && view.tag != 12 && view.tag != 13){
            [view resumeAnimations];
        }
    }
}

-(void)createCountdown:(void (^)(void)) completion{
    Countdown* testCD = [[Countdown alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.475, 1, 0.1)] numberImages:countdownNumbers];
    
    __unsafe_unretained typeof(Countdown*) weak = testCD;
    
    [testCD setAnimationCompleteBlock:^(BOOL success){
        completion();
        [weak animateOut];
        [[Sounds sharedInstance] playSoundEffect:ResumeCountdown loops: 0];
    }];
    
    [testCD setDigitCompleteBlock:^void{
        [[Sounds sharedInstance] playSoundEffect:ResumeCountdown loops: 0];
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
    
    int numOfBeltTiles = ([self propX:3]/imageWidth)+5;//((frame.size.width / imageWidth)*2)+5;
    
    _beltImagesSideExtra = (numOfBeltTiles*imageWidth);;
    
    for(int i = 0; i < numOfBeltTiles; i++){
        UIImageView* beltTile = [[UIImageView alloc] initWithImage:beltTileImage];
        beltTile.frame = CGRectMake([self propX:-1]+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
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
    
    int numOfWheelTiles = ([self propX:3]/imageWidth)+5;//((frame.size.width / imageWidth)*2)+5;
    
    for (NSInteger i = 0; i < numOfWheelTiles; ++i){
        [framesArray addObject:[NSNumber numberWithInt:0]];
    }
    
    for(int i = 0; i < numOfWheelTiles; i++){
        UIImageView* beltWheel = [[UIImageView alloc] initWithImage:beltWheelImage];
        beltWheel.frame = CGRectMake([self propX:-1]+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
        
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
    [self animateAllSockBoxes:delta];

    if (currentGameState != NotPlaying && timerPaused == false) {
        [self updateSoundSpeed]; //TODO handle pause sounds
        [self animateBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self updateSocksOnBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self handleAnimateWheel:delta];
        [self handleForkliftAnimation:delta];
        [self handleTickEfficiency:delta];
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
                                [tutorialView animateSockOneToX:[self propX:0.5] withBeltMoveSpeed:[self getFinalBeltMoveSpeed:beltMoveSpeed]];
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

-(void)updateSoundSpeed{
//    CGFloat r = [self getFinalBeltMoveSpeed:animateBeltMoveSpeed];
//    [Sounds sharedInstance].beltSound.rate = r;
}

-(CGFloat)getFinalBeltMoveSpeed:(CGFloat)baseSpeed{
    return (baseSpeed/100.0)*difficultyCurve.beltMoveSpeedMultiplier;
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
        [self pauseAllSubviewAnimations];
        [self createCountdown:^void{
            [self resumeAllSubviewAnimations];
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
        [[Sounds sharedInstance].beltSound stop];

        [self forceEndGame];
        [self removeInfoBanners];
        [self transitionToGameOver];
        [self switchGameStateTo:NotPlaying];
    }
}

-(void)forceEndGame {
    [[GameData sharedGameData] clearSave];
    [Flurry endTimedEvent:@"game" withParameters:@{@"score":[NSNumber numberWithInt:score], @"numSocks":[self analyticsNumSocks], @"options":@{@"sound":@([[Settings sharedInstance] getCurrentSetting:Sound]), @"sockTypeAlerts":@([[Settings sharedInstance] getCurrentSetting:GameAlertSockType]), @"sockSizeAlerts":@([[Settings sharedInstance] getCurrentSetting:GameAlertSockSize])}}];
    if([self.delegate respondsToSelector:@selector(gameEndScore:)]){
        [self.delegate gameEndScore:score];
    }
}

-(void)removeInfoBanners{
    for(InfoBanner* f in [infoBanners copy]){
        [f stopAnimating];
    }
}

-(NSMutableArray<SockData*>*)getSockDataToSaveGame{
    NSMutableArray<SockData*>* sockData = [[NSMutableArray alloc] init];
    
    for(Sock* s in [socks copy]){
        //TODO confirm conditions for saving sock
        if(s.inAPair == false && s.validSock){
            SockData* data = [[SockData alloc] initWithOrigin:[s getCoreRect].origin id:s.sockId size:s.sockSize onConveyorBelt:s.onConvayorBelt];
            [sockData addObject:data];
        }
//        else if(s.inAPair){
//            [self pointForSock:s];
//        }
    }
    
    return sockData;
}

-(NSNumber*)analyticsNumSocks{
    int i = 0;
    
    for(Sock* s in [socks copy]){
        if(!s.inAPair){
            i++;
        }
    }
    
    return [NSNumber numberWithInt:i];
}

-(void) transitionToGameOver {
    if([self.delegate respondsToSelector:@selector(switchFromGameToGameOver:withScore:)]){
        [self.delegate switchFromGameToGameOver:self withScore:score];
    }
}

-(void)animateAllSocksOneScreenLeft:(CGFloat)duration{
//    for(Sock* s in [socks copy]){
//        CGRect f = s.frame;
//        f.origin.x -= [self propX:1];
//        [UIView animateWithDuration:duration animations:^void{
//            s.frame = f;
//        }];
//    }
}

-(bool)canEndGame{
    bool gameDone = true;
    
    for(Sock* s in socks){
        if(s.animatingIntoBox == true){
            gameDone = false;
        }
    }
    
//    if([self anyClawsAnimating] == true){
//        gameDone = false;
//    }
    return gameDone;
}

-(void)handleGenerateSock:(CGFloat)delta {
    generateSockTimer += delta;
    
    if(generateSockTimer >= difficultyCurve.timeToGenerateSock){
        if(currentGameState == Playing){
            [self generateSock:(score > 5 && [Functions randomNumberBetween:0 maxNumber:100] < 2) ? true : false];
            
//            if(score > 5 && [Functions randomNumberBetween:0 maxNumber:100] < 2){
//                [self generateSock];
//            }
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
    CGRect main = [s getCoreRect];
    return CGRectIntersectsRect(conveyorBeltRect, CGRectMake(main.origin.x+(main.size.width*0.2), main.origin.y+(main.size.height*0.2), main.size.width*0.8, main.size.height*0.8));
//    return CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX([s getCoreRect]), CGRectGetMidY([s getCoreRect])));
}

-(bool)_sockInGameView:(Sock*)s{
    CGRect screen = [self propToRect:CGRectMake(0, 0, 1, 1)];
    CGFloat beltAndTopSize = conveyorBeltRect.origin.y+conveyorBeltRect.size.height;
    return CGRectIntersectsRect([s getCoreRect], CGRectMake(screen.origin.x, screen.origin.y+beltAndTopSize, screen.size.width, screen.size.height-beltAndTopSize));
}

-(bool)_theoreticalSockInGameView:(Sock*)s{
    
    CGFloat adHeight = 0;
    if([self.delegate respondsToSelector:@selector(getAdHeight)]){
        adHeight = [self.delegate getAdHeight];
    }
    
    
    CGRect screen = [self propToRect:CGRectMake(0, 0, 1, 1)];
    CGFloat beltAndTopSize = conveyorBeltRect.origin.y+conveyorBeltRect.size.height;
    return CGRectIntersectsRect([s getCoreTheoreticalRect], CGRectMake(screen.origin.x, screen.origin.y+beltAndTopSize, screen.size.width, screen.size.height-beltAndTopSize-adHeight));
}

-(bool)_theoreticalSockInBeltRect:(Sock*)s{
    CGRect screen = [self propToRect:CGRectMake(0, 0, 1, 1)];
    CGFloat topSize = conveyorBeltRect.origin.y;
    return CGRectIntersectsRect([s getCoreTheoreticalRect], CGRectMake(screen.origin.x, screen.origin.y+topSize, screen.size.width, conveyorBeltRect.size.height));
}

//-(CGRect)_getGameViewRect{
//    CGRect screen = [self propToRect:CGRectMake(0, 0, 1, 1)];
//    CGFloat beltAndTopSize = conveyorBeltRect.origin.y+conveyorBeltRect.size.height;
//    return CGRectMake(screen.origin.x, screen.origin.y+beltAndTopSize, screen.size.width, screen.size.height-beltAndTopSize);
//}

-(bool)spaceForSock:(Sock*)s{
    for(Sock* sock in socks){
        if(CGRectIntersectsRect([s getCoreRect], [sock getCoreRect])){
            
        }
    }
    
    return true;
}

-(void)animateBeltWithSpeed:(CGFloat)speed delta:(CGFloat)delta {
    for (UIImageView* img in conveyorBeltTiles) {
        CGFloat propMoveX = [self getFinalBeltMoveSpeed:speed];
        CGFloat moveX = [self propX:propMoveX];
        CGFloat moveDelta = -moveX*delta;
        
        if(img.frame.origin.x <= [self propX:-1]-img.frame.size.width){
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
                CGFloat propMoveX = [self getFinalBeltMoveSpeed:speed];
                CGFloat moveX = [self propX:propMoveX];
                
                if([sock getCoreRect].origin.x < -[sock getCoreRect].size.width){
                    if(!sock.inAPair){
                        [self sockGotPastBelt];
                    }
//                    else{
//                        [self pointForSock:sock];
//                    }
                    
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
    [[Sounds sharedInstance] playSoundEffect:SockPassed loops:0];
    [self lostEfficiency:10.0];
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

-(void)handleTickEfficiency:(CGFloat)delta{
    efficiencyTickTimer += delta;
    
    if(efficiencyTickTimer >= timeToTickEfficiency){
        [self tickEfficiency];
        efficiencyTickTimer = 0;
    }
}

-(void)tickEfficiency{
    //TODO
//    if([self getNumberOfSocksCanMove] > 13){
//        [self lostEfficiency:1];
//
//        if(![self alreadyHaveTooManySockBanner]){
//            InfoBanner* tooManySocksBanner = [self createInfoBanner:0 text:@"too many socks!"];
//            tooManySocksBanner.tag = 1;
//        }
//    }else{
//        [self gainEfficiency:1];
//
//        for(InfoBanner* b in infoBanners){
//            if(b.tag == 1){
//                [b stopAnimating];
//            }
//        }
//    }
    [self gainEfficiency:1];
}

-(bool)alreadyHaveTooManySockBanner{
    bool alreadyHave = false;
    for(InfoBanner* b in infoBanners){
        if(b.tag == 1){
            alreadyHave = true;
        }
    }
    return alreadyHave;
}

-(int)getNumberOfSocksCanMove{
    int i = 0;
    for(Sock* s in socks){
        //TODO keep onConveyorBelt?
        if(s.inAPair == false && s.validSock == true && s.allowMovement == true && s.onConvayorBelt == false && [self _sockInGameView:s]){
            i++;
        }
    }
    return i;
}

//-(int)calculateTooManySockThreshold{
//    return 5+((difficultyCurve.maxSockSize+1)*[self getNumberOfDifferentSockTypes]);
//}

//-(int)getNumberOfDifferentSockTypes{
//    return (int)difficultyCurve.numOfDifferentSocksToGenerate;
//}

-(void)lostEfficiency:(CGFloat)efficiencyLost {
    efficiency -= efficiencyLost;
    
    if(efficiency > 100){
        efficiency = 100;
    }
    
    if(efficiency >= 0){
        [self updateBarForEfficiency:efficiency];
    }
    
    if(efficiency <= 0){
        [self updateBarForEfficiency:0];
        [self switchGameStateTo:Stopping];
    }
}

-(void)gainEfficiency:(CGFloat)efficiencyGained{
    [self lostEfficiency:-efficiencyGained];
}

-(void)forceSetEfficiency:(CGFloat)efficienc{
    self.efficiency = efficienc;
    [self updateBarForEfficiency:self.efficiency];
}

-(void)updateBarForEfficiency:(CGFloat)efficienc{
    [bar setInnerBarPercentage:efficienc/100.0];
}

-(void)removeFromView:(UIView*)view {
    [view removeFromSuperview];
}

-(void) generateSock:(bool)twoSocks{
    CGFloat y = [Functions randFromMin:0.15 toMax:0.3];
    
    NSArray* sockInfo = [difficultyCurve getNextSock:[self getMovableSocks]];
    NSNumber* sockId = sockInfo[0];
    NSNumber* size = sockInfo[1];
    
    CGPoint newSockPos = [self propToRect:CGRectMake(1.0, y, 0, 0)].origin;
    //imageName:[NSString stringWithFormat:@"sock%i", sockId]
    Sock* one = [self createSockAtPos:newSockPos sockSize:size.intValue sockId:sockId.intValue onBelt:true];
    
    if(twoSocks == true){
        CGFloat y2 = [Functions randFromMin:0.15 toMax:0.3];
      
        NSArray* sockInfo2 = [difficultyCurve getNextSock:[self getMovableSocks]];
        NSNumber* sockId2 = sockInfo2[0];
        NSNumber* size2 = sockInfo2[1];
        CGFloat width2 = [self propX: [Functions propSizeFromSockSize:(SockSize)size2]];
        
        do{
            y2 = [Functions randFromMin:0.15 toMax:0.3];
        }while(CGRectIntersectsRect([self increaseRect:[one getCoreRect] byPercentage:-0.5], CGRectMake([self propX:1], [self propY: y2], width2, width2)));
        
        
        CGPoint newSockPos2 = [self propToRect:CGRectMake(1.0, y2, 0, 0)].origin;
        //imageName:[NSString stringWithFormat:@"sock%i", sockId]
        [self createSockAtPos:newSockPos2 sockSize:size2.intValue sockId:sockId2.intValue onBelt:true];
        
    }
    
}

- (CGRect)increaseRect:(CGRect)rect byPercentage:(CGFloat)percentage
{
    CGFloat startWidth = CGRectGetWidth(rect);
    CGFloat startHeight = CGRectGetHeight(rect);
    CGFloat adjustmentWidth = (startWidth * percentage) / 2.0;
    CGFloat adjustmentHeight = (startHeight * percentage) / 2.0;
    return CGRectInset(rect, -adjustmentWidth, -adjustmentHeight);
}

-(NSMutableArray<SockData*>*)getMovableSocks{
    NSMutableArray<SockData*>* sockData = [[NSMutableArray alloc] init];
    
    for(Sock* s in [socks copy]){
        //TODO confirm conditions for saving sock
        if(s.inAPair == false && s.validSock && s.allowMovement == true){
            SockData* data = [[SockData alloc] initWithOrigin:[s getCoreRect].origin id:s.sockId size:s.sockSize onConveyorBelt:s.onConvayorBelt];
            [sockData addObject:data];
        }
    }
    
    return sockData;
}
-(void) decreaseSockLayerPositions {
    for (Sock* s in socks) {
        s.layer.zPosition = s.layer.zPosition > 0 ? s.layer.zPosition-1 : 0;
    }
}

-(Sock*) createSockAtPos:(CGPoint)pos sockSize:(SockSize)size sockId:(int) sockId onBelt:(bool) onBelt {
    CGFloat width = [self propX: [Functions propSizeFromSockSize:size]];
    UIImage* sockImage = [sockMainImages objectAtIndex:sockId];
    Sock* newSock = [[Sock alloc] initWithFrame:pos width: width sockSize: size sockId: sockId image: sockImage onBelt:true extraPropTouchSpace:0.9];
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
        
        //check if sock is at top of screen
        CGRect top = [self propToRect:CGRectMake(0, 0, 1, 0.15)];
        CGRect sock = [s getCoreTheoreticalRect];//ss.frame;
        if(CGRectIntersectsRect(sock, top)){
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
                [s setRectFromCoreRect:s.startTouchRect];
                [s setTheoreticalRectFromCoreTheoreticalRect:s.startTouchRect];
                //                s.frame = s.theoreticalFrame;
                //                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                [self updateWeatherSockOnBelt:s];
                //                [self checkPairsWithSock:s];
            }];
        }
        
        if([self handleIntersection:s previousOverlap:false direction:0 recursionCount:0]){
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
                s.frame = s.theoreticalFrame;
                //                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                if([self _theoreticalSockInGameView:s] || [self _theoreticalSockInBeltRect:s]){
                    [self updateWeatherSockOnBelt:s];
                }else{
                    [self removeSock:s];
                }
                //                [self checkPairsWithSock:s];
            }];
            

            
        }
    }];
    
    NSLog(@"Creating Sock! %@", NSStringFromCGRect([newSock getCoreRect]));
    newSock.theoreticalFrame = newSock.frame;
    [self updateWeatherSockOnBelt:newSock];
    [self.view addSubview:newSock];
    [socks addObject:newSock];
    
    return newSock;
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
                if(CGRectIntersectsRect(r, f)){// && !(ss.sockId == s.sockId)){
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
                                finalWidth = resolveRect.size.width;
                                break;
                            case 3:
                                finalHeight = resolveRect.size.height;
                                break;
                            case 4:
                                finalWidth = -resolveRect.size.width;
                                break;
                            default:
                                break;
                        }
                    }else if(rc < 12){
                        finalWidth = resolveRect.size.width;
                    }else if(rc < 16){
                        finalHeight = resolveRect.size.height;
                    }else if(rc < 20){
                        finalWidth = -resolveRect.size.width;
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
    otherSock.inAPair = sock.inAPair = true;
    otherSock.mainSockInPair = true;
    
    otherSock.otherSockInPair = sock;
    sock.otherSockInPair = otherSock;
    
    otherSock.allowMovement = false;
    otherSock.layer.zPosition = 15;
    sock.layer.zPosition = 16;
//    otherSock.theoreticalFrame = otherSock.frame;
//    [UIView animateWithDuration:0.25 animations:^void{
//        CGRect f = CGRectOffset(otherSock.frame, (sock.frame.origin.x-otherSock.frame.origin.x)/2, (sock.frame.origin.y-otherSock.frame.origin.y)/2);
//        otherSock.frame = f;
//        sock.frame = f;
//    } completion:^(BOOL completed){
//        [sock removeFromSuperview];
//        [socks removeObject:sock];
//
//        [otherSock.overlayImageView setImage:[boxAnimationFrames objectAtIndex:0]];
//        [socksBeingAnimatedIntoBox addObject:otherSock];
//    }];
    
    //TODO
//    [[Sounds sharedInstance] playSoundEffect:BoxPackaging loops: 0];
    
    [self pointForSock:otherSock];
    
    if(otherSock.onConvayorBelt == false && sock.onConvayorBelt == false){
        otherSock.theoreticalFrame = otherSock.frame;
        [UIView animateWithDuration:0.25 animations:^void{
            CGRect f = CGRectOffset(otherSock.frame, (sock.frame.origin.x-otherSock.frame.origin.x)/2, (sock.frame.origin.y-otherSock.frame.origin.y)/2);
            otherSock.frame = f;
            sock.frame = f;
        } completion:^(BOOL completed){
            [sock removeFromSuperview];
            [socks removeObject:sock];

            [otherSock.overlayImageView setImage:[boxAnimationFrames objectAtIndex:0]];
            [socksBeingAnimatedIntoBox addObject:otherSock];
        }];
    }else{
        //TODO animating here is wierd cuz it is also moving on the belt
        [sock removeFromSuperview];
        [socks removeObject:sock];

        CGRect f = CGRectOffset(otherSock.frame, (sock.frame.origin.x-otherSock.frame.origin.x)/2, (sock.frame.origin.y-otherSock.frame.origin.y)/2);
        otherSock.frame = f;

        [otherSock.overlayImageView setImage:[boxAnimationFrames objectAtIndex:0]];
        [socksBeingAnimatedIntoBox addObject:otherSock];
    }
}

-(void) animateAllSockBoxes:(CGFloat)delta {
    //    NSLog(@"animate all socks %li", socksBeingAnimatedIntoBox.count);
    animateBoxTimer += delta;
    
    if(animateBoxTimer >= animateBoxInterval){
        for (Sock* s in [socksBeingAnimatedIntoBox copy]) {
            [self animateSock:s];
        }
        animateBoxTimer = 0;
    }
}

-(void) animateAllForklifts {
    for (Forklift* f in [forklifts copy]) {
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
        
        if(!s.onConvayorBelt && [_delegate getAppState] == Game){
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

-(void)removeAllSocks{
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    for(int i = 0; i < socks.count; i++){
        [discardedItems addIndex:i];
        [[socks objectAtIndex:i] removeFromSuperview];
    }
    [socks removeObjectsAtIndexes:discardedItems];
}

-(void)removeSock:(Sock*)s{
    [socks removeObject:s];
    [s removeFromSuperview];
}

-(void)createForklift:(Sock*)s givePoint:(BOOL)point{
    Forklift* lift = [[Forklift alloc] initWithSock:s forkliftAnimationFrames:forkLiftAnimationFrames wheelAnimationFrames:wheelFrames];
    lift.givePoint = point;
    lift.layer.zPosition = 8;
    [self.view addSubview:lift];
    [forklifts addObject:lift];
    
    [self handleForkliftNoOverlapAnimationsForLift:lift];
}

-(void)handleForkliftNoOverlapAnimationsForLift:(Forklift*)lift{
    bool clear = true;
    for(Forklift* f in forklifts){
        if(f != lift){
            if(lift.currentState == None && lift.forkliftFacesRight == f.forkliftFacesRight && f.currentState != None){
                
                if(CGRectIntersectsRect(lift.frame, CGRectMake(-1, f.frame.origin.y, [self propX:3], lift.frame.size.height))){
                    clear = false;
                }
            }
        }
    }
    
    if(clear == true && lift.currentState == None){
        CGFloat speed = (1.5/difficultyCurve.beltMoveSpeedMultiplier);
        [lift animateWithSpeed:speed withCompletion:^void{
            [self forkliftAnimationComplete:lift.givePoint sock:[lift getSock] lift:lift];
            for(Forklift* t in forklifts){
                [self handleForkliftNoOverlapAnimationsForLift:t];
            }
        }];
        
    }
}

-(void)forkliftAnimationComplete:(bool)point sock:(Sock*)sock lift:(Forklift*)lift{
//    if(point == true){
//        [self pointForSock:sock];
//    }
    
    [sock removeFromSuperview];
    [socks removeObject:sock];
    
    [lift removeFromSuperview];
    [forklifts removeObject:lift];
}

-(void) pointForSock:(Sock*)s{
    s.allowMovement = false;
    if(s.validSock == true){
//        [[Sounds sharedInstance] playSoundEffect:PointSound loops:0];
        [self gotPoint];
    }
}

//-(void)newSockSize{
////    InfoBanner* b = [self createInfoBanner:3 text:@"new sock size!"];
////    b.tag = 2;
//
//    // TODO use a alert view
//    if([[Settings sharedInstance] getCurrentSetting:GameAlertSockSize] == true){
//        UIImage* sockAlertImage = [sockMainImages objectAtIndex:0];
//
//        GameAlertView* gav = [[GameAlertView alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.25, 0.5, 0.5)] screenFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"new sock size!" text:@"you must match socks that are also the same size!" image: sockAlertImage smallerImg:sockAlertImage];
//        gav.layer.zPosition = 251;
//        timerPaused = true;
//        __unsafe_unretained typeof(GameAlertView*) weak = gav;
//
//        [gav setButtonPressBlock:^void{
//            timerPaused = false;
//            [self enableSockMovement];
//            [weak hideAndRemove];
//        }];
//
//        for(Sock* s in [self->socks copy]){
//            [s animateDecreaseCoreScale];
//            s.touchEndedBlock(s, CGPointZero);
//        }
//        [self disableSockMovement];
//
//        [self.view addSubview:gav];
//    }
//}
//
//- (UIImage*)getNewSockSizeImage:(UIImage*)img {
//    UIImage* newImage = [self resizeImage:img newSize:CGSizeMake(img.size.width*0.4, img.size.height*0.4)];
//
//    UIImage *image = nil;
//
//    CGSize newImageSize = CGSizeMake(img.size.width*1.5, img.size.height);
//
//    UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
//
//
////    [img drawAtPoint:CGPointMake(roundf((img.size.width)/2), roundf((newImageSize.height-img.size.height)/2))];
//    [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
////    [img drawAtPoint:CGPointMake(roundf((newImageSize.width)-(img.size.width/2)), roundf((newImageSize.height-img.size.height)/2))];
//    [img drawInRect:CGRectMake(img.size.width, img.size.height*0.5, img.size.width*0.5, img.size.height*0.5)];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return image;
//}
//
//- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
//    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
//    CGImageRef imageRef = image.CGImage;
//
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    // Set the quality level to use when rescaling
//    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
//    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
//
//    CGContextConcatCTM(context, flipVertical);
//    // Draw into the context; this scales the image
//    CGContextDrawImage(context, newRect, imageRef);
//
//    // Get the resized image from the context and a UIImage
//    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
//    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
//
//    CGImageRelease(newImageRef);
//    UIGraphicsEndImageContext();
//
//    return newImage;
//}

//-(void)newSockType{
////    InfoBanner* b = [self createInfoBanner:3 text:@"new sock type!"];
////    b.tag = 0;
//
//    if([[Settings sharedInstance] getCurrentSetting:GameAlertSockType] == true){
//
//        UIImage* sockAlertImage = nil;
//
//        if(floor(difficultyCurve.numOfDifferentSocksToGenerate) < sockMainImages.count){
//            sockAlertImage = [sockMainImages objectAtIndex:floor(difficultyCurve.numOfDifferentSocksToGenerate)];
//        }
//
//        GameAlertView* gav = [[GameAlertView alloc] initWithFrame:[self propToRect:CGRectMake(0.25, 0.25, 0.5, 0.5)] screenFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"new sock type!" text:@"there is a new sock to match!" image: sockAlertImage];
//        gav.layer.zPosition = 251;
//        timerPaused = true;
//        __unsafe_unretained typeof(GameAlertView*) weak = gav;
//
//        [gav setButtonPressBlock:^void{
//            timerPaused = false;
//            [self enableSockMovement];
//            [weak hideAndRemove];
//        }];
//
//        for(Sock* s in [self->socks copy]){
//            [s animateDecreaseCoreScale];
//            s.touchEndedBlock(s, CGPointZero);
//        }
//        [self disableSockMovement];
//
//        [self.view addSubview:gav];
//    }
//}

-(InfoBanner*)createInfoBanner:(int)times text:(NSString*)text{
    CGFloat y = 0.55+(((int)infoBanners.count-1)*0.05);
    InfoBanner* banner = [[InfoBanner alloc] initWithFrame:[self propToRect:CGRectMake(0, y, 1, 0.05)] repeatTime:times text:text];
    
    __unsafe_unretained typeof(InfoBanner*) wb = banner;
    
    [banner setBlock:^void{
        [infoBanners removeObject:wb];
        [self updateInfoBannerPositions];
    }];
    
    banner.layer.zPosition = 120+(infoBanners.count);
    
    [self.view addSubview:banner];
    [infoBanners addObject:banner];
    return banner;
}

-(void)updateInfoBannerPositions{
    CGFloat current = 0.45;
    for(int i = 0; i < infoBanners.count; i++){
        InfoBanner* banner = [infoBanners objectAtIndex:i];
        [UIView animateWithDuration:0.5 animations:^void{
            CGRect f = banner.frame;
            f.origin.y = [self propY:current];
            banner.frame = f;
        }];
        current += (i*0.05);
    }
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
