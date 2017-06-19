//
//  GameViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameViewController.h"
#import "Sock.h"
#import "Functions.h"

@interface GameViewController () {
    BOOL gameActive;
    BOOL endingGame;
    
    CADisplayLink* gameTimer;
    
    CGFloat timeToGenerateSock;
    CGFloat generateSockTimer;
    
    CGFloat sockMatchThreshold;
    
    NSMutableArray <Sock*>* socks;
    
    CGRect convayorBeltRect;
    CGFloat beltMoveSpeed;
    NSMutableArray <UIImageView*>* conveyorBeltTiles;
    
    NSMutableArray <UIImageView*>* bottomConveyorBeltWheels;
    NSMutableArray <NSNumber*>* bottomConveyorBeltWheelsFrames;
    NSMutableArray <UIImageView*>* topConveyorBeltWheels;
    NSMutableArray <NSNumber*>* topConveyorBeltWheelsFrames;
    
    NSMutableArray <UIImage*>* wheelFrames;
    
    UILabel* scoreLabel;
    NSMutableArray <UIImageView*>* scoreDigits;
    NSMutableArray <UIImage*>* scoreDigitImages;
    
    UILabel* tutorialLabel;
    UILabel* bottomTutorialLabel;
    
    int score;
    int lives;
    NSMutableArray <UIImageView*>* lifeLights;
    UIImage* lifeLightOff;
    UIImage* lifeLightOn;
    
    CGFloat _beltImagesSideExtra;
    
    CGFloat timeToAnimateWheels;
    CGFloat animateWheelTimer;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupGameValues];
    [self createUI];
    [self createBeltAndWheels];
}

-(void)beginGame {
    [self resetGame];

    gameActive = true;
    NSLog(@"Begin game");
    [self startGameLoop];
    [self performSelector:@selector(removeFromView:) withObject:tutorialLabel afterDelay:15];
    [self performSelector:@selector(removeFromView:) withObject:bottomTutorialLabel afterDelay:25];
}

-(void)endGame {
    gameActive = false;
    endingGame = true;
    [self finishEndingGame];
}

-(void) finishEndingGame {    
    NSLog(@"transitioning to game over");
    id<GameTransition> strongDelegate = self.delegate;
    
    if([strongDelegate respondsToSelector:@selector(switchFromGameToGameOver:withScore:)]){
        [strongDelegate switchFromGameToGameOver:self withScore:score];
    }
}

-(void)startGameLoop {
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameFrame:)];
    gameTimer.preferredFramesPerSecond = 60;
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)pauseGameLoop {
    gameActive = false;
    [gameTimer setPaused:true];
}

-(void)resumeGameLoop {
    gameActive = true;
    [gameTimer setPaused:false];
}

-(void)stopGameLoop {
    [gameTimer setPaused:true];
    [gameTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    gameTimer = nil;
}

-(void)resetGame {
    for (Sock* sock in socks) {
        [sock removeFromSuperview];
    }
    
    for(UIImageView* img in lifeLights){
        [img setImage:lifeLightOff];
    }
    
    [self setupGameValues];
    [self setScoreImages:score];
}

-(void)setupGameValues {
    gameActive = false;
    endingGame = false;
    score = 0;
    lives = 3;
    timeToGenerateSock = 1.5;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.06];
    socks = [[NSMutableArray alloc] init];
    beltMoveSpeed = 20.0;
    
    timeToAnimateWheels = 0.05;
    animateWheelTimer = 0;
}

-(void)createUI {
    lifeLights = [[NSMutableArray alloc] init];
    convayorBeltRect = [self propToRect:CGRectMake(0, 0.15, 1, 0.3)];

    UIView* topBackground = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 1, 0.15)]];
    topBackground.backgroundColor = [UIColor colorWithRed:0.9960784314 green:0.8549019608 blue:0.1176470588 alpha:1];
    topBackground.layer.zPosition = -50;
    [self.view addSubview:topBackground];
    
    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.6, 0.05, 0.3, 0.1)]];
    scoreLabel.layer.borderColor = [UIColor blackColor].CGColor;
    scoreLabel.layer.borderWidth = 2;
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:26];
    scoreLabel.text = @"0";
//    [self.view addSubview:scoreLabel];
    
    scoreDigitImages = [[NSMutableArray alloc] init];
    for(int i = 0; i < 10; i++){
        UIImage* digitImg = [UIImage imageNamed:[NSString stringWithFormat:@"digit_%i", i]];
        [scoreDigitImages addObject:digitImg];
    }
    
    scoreDigits = [[NSMutableArray alloc] init];
    CGPoint scoreDigitStartPos = CGPointMake(0.545, 0.035);
    CGSize scoreDigitSize = CGSizeMake(0.11, 0.08);
    for(int i = 0; i < 4; i++){
        UIImageView* scoreDig = [[UIImageView alloc] initWithFrame:[self propToRect:CGRectMake(scoreDigitStartPos.x+(i*scoreDigitSize.width), scoreDigitStartPos.y, scoreDigitSize.width, scoreDigitSize.height)]];
        scoreDig.tag = -i;
        scoreDig.contentMode = UIViewContentModeScaleAspectFit;
        scoreDig.layer.magnificationFilter = kCAFilterNearest;
//        scoreDig.layer.borderWidth = 2;
//        scoreDig.layer.borderColor = [UIColor grayColor].CGColor;
        [scoreDigits addObject:scoreDig];
        [self.view addSubview:scoreDig];
    }
    [self setScoreImages:score];
    
    lifeLightOff = [UIImage imageNamed:@"redlightoff"];
    lifeLightOn = [UIImage imageNamed:@"redlighton"];
    
    for(int i = 0; i < 3; i++){
        CGRect lightRect = [self propToRect:CGRectMake(0.05+(i*0.16), 0.03, 0.15, 0)];
        UIImageView* rl = [[UIImageView alloc] initWithFrame: CGRectMake(lightRect.origin.x, lightRect.origin.y, lightRect.size.width, lightRect.size.width)];
        rl.layer.zPosition = 50;
        rl.contentMode = UIViewContentModeScaleAspectFill;
        rl.layer.magnificationFilter = kCAFilterNearest;
        
        [rl setImage:lifeLightOff];
        [self.view addSubview:rl];
        [lifeLights addObject:rl];
        NSLog(@"added light %i", i);
    }
    
    tutorialLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.45, 1, 0.075)]];
    tutorialLabel.text = @"match socks together based on style and size";
    tutorialLabel.textAlignment = NSTextAlignmentCenter;
    //    tutorialLabel.layer.borderColor = [UIColor blackColor].CGColor;
    //    tutorialLabel.layer.borderWidth = 2;
    [self.view addSubview:tutorialLabel];
    
    CGRect btmTutFrame = [self propToRect:CGRectMake(0, 0.525, 1, 0.075)];
    bottomTutorialLabel = [[UILabel alloc] initWithFrame: btmTutFrame];
    bottomTutorialLabel.text = @"use the area down here to match";
    bottomTutorialLabel.textAlignment = NSTextAlignmentCenter;
    //    bottomTutorialLabel.layer.borderColor = [UIColor blackColor].CGColor;
    //    bottomTutorialLabel.layer.borderWidth = 2;
    [self.view addSubview:bottomTutorialLabel];
}

-(void)createBeltAndWheels {
    wheelFrames = [[NSMutableArray alloc] init];
    for(int i = 0; i < 4; i++){
        UIImage* img = [UIImage imageNamed:[NSString stringWithFormat:@"wheel_%i", i]];
        [wheelFrames addObject:img];
    }
    
    conveyorBeltTiles = [self createConveyorBelt:convayorBeltRect];
    
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
    
    UIImage* beltTileImage = [UIImage imageNamed:@"beltTileNoWheel"];
    
    CGFloat aspectRatio = frame.size.height / beltTileImage.size.height;
    CGFloat imageWidth = beltTileImage.size.width*aspectRatio;
    
    int numOfBeltTiles = (frame.size.width / imageWidth)*2;
    
    _beltImagesSideExtra = (numOfBeltTiles*imageWidth);//-frame.size.width;
    
    for(int i = 0; i < numOfBeltTiles; i++){
        UIImageView* beltTile = [[UIImageView alloc] initWithImage:beltTileImage];
        
        
        beltTile.frame = CGRectMake(frame.origin.x+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
//        beltTile = UIViewContentModeScaleAspectFit;//UIViewContentModeScaleAspectFill;
        beltTile.layer.magnificationFilter = kCAFilterNearest;
        beltTile.tag = i;
        
        
        [self.view addSubview:beltTile];
        [beltTiles addObject:beltTile];
    }
    
    return beltTiles;
}

-(void) createConveyorBeltWheels:(CGRect)frame imageArray:(NSMutableArray <UIImageView*>*)beltWheels forArray:(NSMutableArray <NSNumber*>*) framesArray{
    
    UIImage* beltWheelImage = [UIImage imageNamed:@"wheel_0"];
    
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
        UIImage* newWheelImage = [UIImage imageNamed:[NSString stringWithFormat:@"wheel_%i", x.intValue]];
        [beltWheel setImage:newWheelImage];
    
        [framesArray replaceObjectAtIndex:i withObject:x];
        
        [self.view addSubview:beltWheel];
        [beltWheels addObject:beltWheel];
    }
}

-(void) gameFrame:(CADisplayLink*)tmr {
    [self animateBelt:tmr.duration];
    [self updateSocksOnBeltWithDelta:tmr.duration];
    
    generateSockTimer += tmr.duration;
    animateWheelTimer += tmr.duration;
    
    if(generateSockTimer >= timeToGenerateSock){
        if(gameActive == true){
            [self generateSock];
        }
        generateSockTimer = 0;
    }
    
    if(animateWheelTimer >= timeToAnimateWheels){
        [self animateWheels:bottomConveyorBeltWheels withFrames:bottomConveyorBeltWheelsFrames];
        [self animateWheels:topConveyorBeltWheels withFrames:topConveyorBeltWheelsFrames];
        
        animateWheelTimer = 0;
    }
    
    if(endingGame == true){
        //TODO keep belt moving until no more socks on belt, then slow down
        beltMoveSpeed -= tmr.duration*6;
        timeToAnimateWheels += tmr.duration/4;
        
        if(beltMoveSpeed <= 0){
            [self stopGameLoop];
        }
    }
}


-(void)animateBelt:(CGFloat)delta {
    for (UIImageView* img in conveyorBeltTiles) {
        CGFloat propMoveX = beltMoveSpeed/100.0;
        CGFloat moveX = [self propX:propMoveX];
        CGFloat moveDelta = -moveX*delta;
        
        if(img.frame.origin.x <= -img.frame.size.width){
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

-(void) updateSocksOnBeltWithDelta:(CGFloat)delta {
    for(int i = 0; i < socks.count; i++){
        Sock* sock = [socks objectAtIndex:i];
        
        if(sock != nil){
            if(sock.onConvayorBelt == true){
                if(sock.inAPair == false){
                    CGFloat propMoveX = beltMoveSpeed/100.0;
                    CGFloat moveX = [self propX:propMoveX];
                    
                    if(sock.frame.origin.x < -sock.frame.size.width){
                        [self lostLife];
                        sock.onConvayorBelt = false;
                        
                        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                            //Background Thread
                            [socks removeObject:sock];
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                //Run UI Updates
                                [sock removeFromSuperview];
                            });
                        });
                    }
                    
                    sock.frame = CGRectOffset(sock.frame, -moveX*delta, 0);
                }
            }
        }else{
            NSLog(@"NO SOCK WHILE UPDATING BELT");
        }
    }
}

-(void) gotPoint {
    timeToGenerateSock = timeToGenerateSock >= 1 ? timeToGenerateSock -= 0.025 : 1;
    
    score += 1;
    [self setScoreImages:score];
}

-(void) setScoreImages:(int) s {
    NSString* scoreStr = [NSString stringWithFormat:@"%i", s];
    
    if(scoreStr.length <= 4){
        for (int i = 0; i < scoreStr.length; i++) {
            int ni = (int)scoreStr.length-i-1;
            int ii = (int)scoreDigits.count-i-1; //imageview index
            unichar ch = [scoreStr characterAtIndex:ni];
            NSString* digit = [NSString stringWithFormat:@"%c", ch];
            UIImageView* digitView = [scoreDigits objectAtIndex:ii];
            NSLog(@"SCORE %i %i %i %i", s, score, ni, digit.intValue);
            UIImage* digitImage = [scoreDigitImages objectAtIndex:digit.intValue];
            
            [digitView setImage: digitImage];
        }
    }else{
        NSLog(@"MORE THAN FOUR DIGITS %@", scoreStr);
    }
}

-(void) lostLife {
    NSLog(@"lost life");
    if(lives > 0 && lives <= 3){
        UIImageView* light = [lifeLights objectAtIndex:3-lives];
        [light setImage:lifeLightOn];
    }
    
    lives -= 1;
    if(lives <= 0){
        NSLog(@"Game Over!");
        [self endGame];
    }
}

//TODO the perform selector causes the closest(why?) sock to jerk back...?
-(void)setBackgroundColorClear:(UIView*)view {
    view.backgroundColor = [UIColor clearColor];
}

-(void)removeFromView:(UIView*)view {
    [view removeFromSuperview];
}

-(void) generateSock{
    CGFloat y = [Functions randFromMin:0.15 toMax:0.3];
    
    int sockId = [self getRandomSockId];
    SockSize size = [self getRandomSockSize];
    
    CGRect newSockFrame = [self propToRect:CGRectMake(1.0, y, [Functions propSizeFromSockSize:size], 0)];
    [self createSockAtPos:newSockFrame.origin width:newSockFrame.size.width sockSize:size sockId:sockId imageName:[NSString stringWithFormat:@"sock%i", sockId] onBelt:true];
    
}

-(int) getRandomSockId {
    return [Functions randomNumberBetween:0 maxNumber:4];
}

-(SockSize) getRandomSockSize {
    return [Functions randomNumberBetween:0 maxNumber:2];
}

-(void) createSockAtPos:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int) sockId imageName:(NSString*) imageName onBelt:(bool) onBelt {
    
    Sock* newSock = [[Sock alloc] initWithFrame:pos width: width sockSize: size sockId: sockId imageName: imageName onBelt:onBelt];
//    newSock.layer.borderWidth = 2;
//    newSock.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [newSock setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        s.onConvayorBelt = false;
    }];
    
    [newSock setTouchMovedBlock:^void (Sock* s, CGPoint p) {
        s.onConvayorBelt = false;
        
        if((!s.inAPair || s.mainSockInPair) && s.otherSockInPair != nil){
            CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:s.sockSize]/10.0];
            s.otherSockInPair.center = CGPointMake(s.center.x-matchedPairPositionOffset, s.center.y+matchedPairPositionOffset); // set center
        }
        
        [self checkPairsWithSock:s];
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.frame), CGRectGetMidY(s.frame)));
        s.onConvayorBelt = onBelt;
    }];
    
    [self.view addSubview:newSock];
    [socks addObject:newSock];
}

-(void) checkPairsWithSock:(Sock*)sock{
    for(int i = 0; i < socks.count; i++){
        Sock* otherSock = [socks objectAtIndex:i];
        
        if(otherSock != sock && sock.inAPair == false && otherSock.inAPair == false){
            bool pairFormed = [self socksFormPairWith:sock andOther:otherSock];
            
            if(pairFormed == true){
                [self madePairBetweenMainSock:sock andOtherSock:otherSock];
            }
        }
    }
}

-(void) madePairBetweenMainSock:(Sock*)sock andOtherSock:(Sock*)otherSock {
    [otherSock removeFromSuperview];
    [socks removeObject:otherSock];
    
    sock.inAPair = otherSock.inAPair = true;
    sock.mainSockInPair = true;
    
    sock.otherSockInPair = otherSock;
    otherSock.otherSockInPair = sock;
    
    [sock setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sock%ipackage", sock.sockId]]];
    
    [self gotPoint];
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

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
