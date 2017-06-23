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

#define SOCK_HIGHEST_LAYER (50)

@interface GameViewController () {
    BOOL warmingUpGame;
    CGFloat finalBeltSpeedWarmUp;
    CGFloat finalWheelSpeedWarmUp;
    BOOL gameActive;
    BOOL endingGame;
    
    CADisplayLink* gameTimer;
    
    CGFloat timeToGenerateSock;
    CGFloat generateSockTimer;
    
    CGFloat sockMatchThreshold;
    
    NSMutableArray <UIImage*>* sockMainImages;
    NSMutableArray <Sock*>* socks;
    NSMutableArray <Sock*>* socksBeingAnimatedIntoBox;
    
    CGRect convayorBeltRect;
    NSMutableArray <UIImageView*>* conveyorBeltTiles;
    
    NSMutableArray <UIImageView*>* bottomConveyorBeltWheels;
    NSMutableArray <NSNumber*>* bottomConveyorBeltWheelsFrames;
    NSMutableArray <UIImageView*>* topConveyorBeltWheels;
    NSMutableArray <NSNumber*>* topConveyorBeltWheelsFrames;
    
    NSMutableArray <UIImage*>* wheelFrames;
    
    NSMutableArray <UIImageView*>* scoreDigits;
    NSMutableArray <UIImage*>* scoreDigitImages;
    
    UILabel* tutorialLabel;
    UILabel* bottomTutorialLabel;
    
    int score;
    int currentAnimatingScore;
    CGFloat timeToAnimateScoreValue;
    CGFloat animateScoreValueTimer;
    
    int lives;
    NSMutableArray <UIImageView*>* lifeLights;
    UIImage* lifeLightOff;
    UIImage* lifeLightOn;
    
    CGFloat _beltImagesSideExtra;
    
    CGFloat timeToAnimateWheels;
    CGFloat animateWheelTimer;
    
    NSMutableArray <UIImage*>* boxAnimationFrames;
    NSMutableArray <UIImage*>* sockPackages;
    
    CGFloat timeForClawAnimation;
    CGFloat clawAnimationTimer;
    
    NSMutableArray <Claw*>* claws;
    NSMutableArray <UIImage*>* clawAnimationFrames;
}

@end

@implementation GameViewController

@synthesize beltMoveSpeed;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadBufferImages];
    
    [self setupGameValues];
    [self createUI];
    [self createBeltAndWheels];
}

-(void)loadBufferImages {
    boxAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_box"] withYRow:5 withXColumn:4 maxFrames:0];
    clawAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_claw"] withYRow:1 withXColumn:4 maxFrames:0];
    wheelFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_wheels"] withYRow:1 withXColumn:4 maxFrames:0];
    sockPackages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockPackage"] withYRow:5 withXColumn:5 maxFrames:5];
    sockMainImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockMain"] withYRow:5 withXColumn:5 maxFrames:5];
    
    scoreDigitImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"numbers"] withYRow:1 withXColumn:10 maxFrames:0];
}

-(void) warmupGame {
    [self resetGame];
    warmingUpGame = true;
    [self startGameLoop];
}

-(void)beginGame {
    gameActive = true;
    warmingUpGame = false;
    
    [self performSelector:@selector(removeFromView:) withObject:tutorialLabel afterDelay:15];
    [self performSelector:@selector(removeFromView:) withObject:bottomTutorialLabel afterDelay:25];
}

-(void)endGame {
    warmingUpGame = false;
    gameActive = false;
    endingGame = true;
//    [self finishEndingGame];
}

-(void) finishEndingGame {
    [self disableSockMovement];
    [self turnLightsOff];
    
    id<GameHandler> strongDelegate = self.gameHandler;
    
    if([strongDelegate respondsToSelector:@selector(switchFromGameToGameOver:withScore:)]){
        [strongDelegate switchFromGameToGameOver:self withScore:score];
    }
}

-(void)startGameLoop {
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameFrame:)];
    gameTimer.preferredFramesPerSecond = 60;
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

//-(void)pauseGameLoop {
//    gameActive = false;
//    warmingUpGame = false;
//    [gameTimer setPaused:true];
//}
//
//-(void)resumeGameLoop {
//    gameActive = true;
//    warmingUpGame = false;
//    [gameTimer setPaused:false];
//}

//TODO use this
-(void)stopGameLoop {
    [gameTimer setPaused:true];
    [gameTimer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    gameTimer = nil;
}

-(void)resetGame {
    for (Sock* sock in socks) {
        [sock removeFromSuperview];
    }
    
    [self turnLightsOff];
    
    [self setupGameValues];
    
}

-(void)turnLightsOff {
    for(UIImageView* img in lifeLights){
        [img setImage:lifeLightOff];
    }
}

-(void)disableSockMovement {
    for (Sock* sock in socks) {
        sock.allowMovement = false;
        sock.validSock = false;
    }
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
    claws = [[NSMutableArray alloc] init];
    
    beltMoveSpeed = 25.0;
    finalBeltSpeedWarmUp = beltMoveSpeed;
    beltMoveSpeed = 0;
    
    timeToAnimateWheels = 0.01;
    finalWheelSpeedWarmUp = timeToAnimateWheels;
    timeToAnimateWheels = 1;
    animateWheelTimer = 0;
    
    timeForClawAnimation = 0.05;
    clawAnimationTimer = 0;
    
    timeToAnimateScoreValue = 0.04;
    animateScoreValueTimer = 0;
    
    socksBeingAnimatedIntoBox = [[NSMutableArray alloc] init];
}

-(void)createUI {
    
    lifeLights = [[NSMutableArray alloc] init];
    convayorBeltRect = [self propToRect:CGRectMake(0, 0.15, 1, 0.3)];

    UIView* topBackground = [[UIView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 1, 0.15)]];
    topBackground.backgroundColor = [UIColor colorWithRed:1 green:0.8 blue:0.2 alpha:1];
    topBackground.layer.zPosition = -5;
    [self.view addSubview:topBackground];
    
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
    //TODO, setup with all time high score?
    [self setScoreImages:0];
    
    lifeLightOff = [UIImage imageNamed:@"redlightoff"];
    lifeLightOn = [UIImage imageNamed:@"redlighton"];
    
    for(int i = 0; i < 3; i++){
        CGRect lightRect = [self propToRect:CGRectMake(0.025+(i*0.16)+(i*0.015), 0.035, 0.15, 0)];
        UIImageView* redLight = [[UIImageView alloc] initWithFrame: CGRectMake(lightRect.origin.x, lightRect.origin.y, lightRect.size.width, lightRect.size.width)];
        redLight.layer.zPosition = 5;
        redLight.contentMode = UIViewContentModeScaleAspectFill;
        redLight.layer.magnificationFilter = kCAFilterNearest;
        
        [redLight setImage:lifeLightOff];
        [self.view addSubview:redLight];
        [lifeLights addObject:redLight];
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
    
    UIImage* beltTileImage = [UIImage imageNamed:@"belt"];
//    beltTileImage = [beltTileImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    beltTileImage = [self image:beltTileImage WithTint:[UIColor blackColor]];
    
    CGFloat aspectRatio = frame.size.height / beltTileImage.size.height;
    CGFloat imageWidth = beltTileImage.size.width*aspectRatio;
    
    int numOfBeltTiles = (frame.size.width / imageWidth)*2;
    
    _beltImagesSideExtra = (numOfBeltTiles*imageWidth);//-frame.size.width;
    
    for(int i = 0; i < numOfBeltTiles; i++){
        UIImageView* beltTile = [[UIImageView alloc] initWithImage:beltTileImage];
        beltTile.frame = CGRectMake(frame.origin.x+(i*imageWidth), frame.origin.y, imageWidth, frame.size.height);
        beltTile.layer.magnificationFilter = kCAFilterNearest;
        beltTile.tag = i;
//        beltTile.tintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        [self.view addSubview:beltTile];
        [beltTiles addObject:beltTile];
    }
    
    return beltTiles;
}

- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions (image.size, NO, image.scale); // for correct resolution on retina, thanks @MobileVet
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // image drawing code here
//    CGContextSetBlendMode(context, kCGBlendModeNormal);
//    CGContextDrawImage(context, rect, image.CGImage);
//
//    // tint image (loosing alpha) - the luminosity of the original image is preserved
//    CGContextSetBlendMode(context, kCGBlendModeMultiply);
//    [tintColor setFill];
//    CGContextFillRect(context, rect);
//
//    // mask by alpha values of original image
//    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
//    CGContextDrawImage(context, rect, image.CGImage);
    
    
    CGContextSetBlendMode (context, kCGBlendModeMultiply);
    
    CGContextDrawImage(context, rect, image.CGImage);
    
    CGContextClipToMask(context, rect, image.CGImage);
    
    CGContextSetFillColorWithColor(context, tintColor.CGColor);
    
    CGContextFillRect(context, rect);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
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

-(void) gameFrame:(CADisplayLink*)tmr {
    [self callSuperUpdateLoop:tmr.duration];
    [self animateBelt:tmr.duration];
    [self updateSocksOnBeltWithDelta:tmr.duration];
    
    generateSockTimer += tmr.duration;
    animateWheelTimer += tmr.duration;
    clawAnimationTimer += tmr.duration;
    animateScoreValueTimer += tmr.duration;
    
    if(warmingUpGame){
        beltMoveSpeed += tmr.duration*8;
        timeToAnimateWheels -= tmr.duration/4;
        
        if(timeToAnimateWheels <= finalWheelSpeedWarmUp){
            timeToAnimateWheels = finalWheelSpeedWarmUp;
        }
        
        if(beltMoveSpeed >= finalBeltSpeedWarmUp){
            beltMoveSpeed = finalBeltSpeedWarmUp;
            timeToAnimateWheels = finalWheelSpeedWarmUp;
            
            [self beginGame];
            warmingUpGame = false;
        }
    }
    
    
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
    
    [self animateAllSockBoxes];
    
    if(clawAnimationTimer >= timeForClawAnimation){
        [self animateAllClaws];
        clawAnimationTimer = 0;
    }
    
    if(animateScoreValueTimer >= timeToAnimateScoreValue){
        [self animateScore];
        animateScoreValueTimer = 0;
    }
    
    if(endingGame == true){
        
//        if(![self anySocksOnConveyorBelt] && ![self anyClawsAnimating]){
            beltMoveSpeed -= tmr.duration*6;
            timeToAnimateWheels += tmr.duration/4;
            
            if(beltMoveSpeed <= 0){
                [self cleanUpSocksWithClaws];
                [self finishEndingGame];
                [self stopGameLoop];
            }
//        }
    }
}

-(void) callSuperUpdateLoop:(CGFloat)delta{
    id<GameHandler> strongDelegate = self.gameHandler;
    
    if([strongDelegate respondsToSelector:@selector(gameLoop:)]){
        [strongDelegate gameLoop:delta];
    }
}

-(BOOL) anySocksOnConveyorBelt {
    bool anySockOnBelt = false;
    for (Sock* sock in socks) {
        bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(sock.frame), CGRectGetMidY(sock.frame)));
        if(onBelt == true || sock.onConvayorBelt){
            anySockOnBelt = true;
        }
    }
    return anySockOnBelt;
}

-(BOOL) anyClawsAnimating {
    bool anyClawsAnimating = false;
    for (Claw* claw in claws) {
        if(claw.currentlyAnimating == true){
            anyClawsAnimating = true;
        }
    }
    return anyClawsAnimating;
}

-(void)animateBelt:(CGFloat)delta {
    for (UIImageView* img in conveyorBeltTiles) {
        CGFloat propMoveX = beltMoveSpeed/100.0;
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

-(void) updateSocksOnBeltWithDelta:(CGFloat)delta {
    for(int i = 0; i < socks.count; i++){
        Sock* sock = [socks objectAtIndex:i];
        
        if(sock != nil){
            if(sock.onConvayorBelt == true){
                CGFloat propMoveX = beltMoveSpeed/100.0;
                CGFloat moveX = [self propX:propMoveX];
                
                if(sock.frame.origin.x < -sock.frame.size.width){
                    if(!sock.inAPair){
                        [self lostLife];
                    }else{
                        [self pointForSock:sock];
                    }
                    
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
                sock.theoreticalFrame = sock.frame;
            }
        }else{
//            NSLog(@"NO SOCK WHILE UPDATING BELT");
        }
    }
}

-(void) gotPoint {
    timeToGenerateSock = timeToGenerateSock >= 1 ? timeToGenerateSock -= 0.025 : 1;
    
    score += 1;
}

-(void) animateScore {
    if(currentAnimatingScore != score){
        currentAnimatingScore = currentAnimatingScore < score ? currentAnimatingScore+1 : currentAnimatingScore-1;
        [self setScoreImages:currentAnimatingScore];
    }
}

-(void) setScoreImages:(int) s {
    NSString* scoreStr = [NSString stringWithFormat:@"%i", s];
    
    if(scoreStr.length <= 4){
        for(int i = 0; i < scoreDigits.count; i++){
            UIImageView* digitView = [scoreDigits objectAtIndex:i];
            [digitView setImage: nil];
        }
        
        for (int i = 0; i < scoreStr.length; i++) {
            int ni = (int)scoreStr.length-i-1;
            int ii = (int)scoreDigits.count-i-1; //imageview index
            unichar ch = [scoreStr characterAtIndex:ni];
            NSString* digit = [NSString stringWithFormat:@"%c", ch];
            UIImageView* digitView = [scoreDigits objectAtIndex:ii];
            UIImage* digitImage = [scoreDigitImages objectAtIndex:digit.intValue];
            
            [digitView setImage: digitImage];
        }
    }else{
//        NSLog(@"MORE THAN FOUR DIGITS %@", scoreStr);
    }
}

-(void) lostLife {
//    NSLog(@"lost life");
    if(lives > 0 && lives <= 3){
        UIImageView* light = [lifeLights objectAtIndex:3-lives];
        [light setImage:lifeLightOn];
    }
    
    lives -= 1;
    if(lives <= 0){
//        NSLog(@"Game Over!");
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
    //imageName:[NSString stringWithFormat:@"sock%i", sockId]
    [self createSockAtPos:newSockFrame.origin width:newSockFrame.size.width sockSize:size sockId:sockId onBelt:true];
    
}

-(int) getRandomSockId {
    return [Functions randomNumberBetween:0 maxNumber:4];
}

-(SockSize) getRandomSockSize {
    return [Functions randomNumberBetween:1 maxNumber:1];
}

-(void) decreaseSockLayerPositions {
    for (Sock* s in socks) {
        s.layer.zPosition = s.layer.zPosition > 0 ? s.layer.zPosition-1 : 0;
    }
}

-(void) createSockAtPos:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int) sockId onBelt:(bool) onBelt {
    UIImage* sockImage = [sockMainImages objectAtIndex:sockId];
    Sock* newSock = [[Sock alloc] initWithFrame:pos width: width sockSize: size sockId: sockId image: sockImage onBelt:onBelt];
//    newSock.layer.borderWidth = 2;
//    newSock.layer.borderColor = [UIColor whiteColor].CGColor;
    
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
            
            //TODO collisions
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
            
    //        if((!s.inAPair || s.mainSockInPair) && s.otherSockInPair != nil){
    //            CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:s.sockSize]/10.0];
    //            s.otherSockInPair.center = CGPointMake(s.center.x-matchedPairPositionOffset, s.center.y+matchedPairPositionOffset); // set center
    //        }
            
            [self checkPairsWithSock:s];
        }
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.frame), CGRectGetMidY(s.frame)));
            s.onConvayorBelt = onBelt;
        }
        
        if([self handleIntersection:s previousOverlap:false]){
            [UIView animateWithDuration:0.5 animations:^void{
                s.frame = s.theoreticalFrame;
                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                [self checkPairsWithSock:s];
//                [self handleIntersection:s];
            }];
        }else{
            
        }
    }];
    
    [self.view addSubview:newSock];
    [socks addObject:newSock];
}

// bool there was overlap
-(bool) handleIntersection:(Sock*)s previousOverlap:(bool)prevOverlap {
    bool overlap = false;
    for(Sock* ss in socks){
        if(ss != s){
            if(CGRectIntersectsRect(ss.frame, s.theoreticalFrame) && !(ss.sockId == s.sockId)){
                overlap = true;
                
                CGRect f = s.theoreticalFrame;
                CGRect resolveRect = CGRectIntersection(f, ss.frame);
                CGRect newDirectionRect = resolveRect;//CGRectMake(0, 0, resolveRect.size.width < f.size.width/2 ? -resolveRect.size.width : resolveRect.size.width, resolveRect.size.height < f.size.height/2 ? -resolveRect.size.height : resolveRect.size.height);
                CGRect newFrame = CGRectMake(f.origin.x+newDirectionRect.size.width, f.origin.y+newDirectionRect.size.height, f.size.width, f.size.height);
//                s.frame = newFrame;
                s.theoreticalFrame = newFrame;
                return [self handleIntersection:s previousOverlap:true];
            }
        }
    }
    return prevOverlap;
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
    [sock removeFromSuperview];
    [socks removeObject:sock];
    
    otherSock.inAPair = sock.inAPair = true;
    otherSock.mainSockInPair = true;
    
    otherSock.otherSockInPair = sock;
    sock.otherSockInPair = otherSock;
    
    [otherSock.overlayImageView setImage:[boxAnimationFrames objectAtIndex:0]];
    
    otherSock.allowMovement = false;
    
    [socksBeingAnimatedIntoBox addObject:otherSock];
}

-(void) animateAllSockBoxes {
//    NSLog(@"animate all socks %li", socksBeingAnimatedIntoBox.count);
    for (Sock* s in socksBeingAnimatedIntoBox) {
        [self animateSock:s];
    }
}

-(void) animateAllClaws {
    for (Claw* c in claws) {
        [c animateAnimation];
    }
}


-(void) animateSock:(Sock*)s{
    NSInteger currentFrame = [boxAnimationFrames indexOfObject:s.overlayImageView.image];
    NSInteger nextFrame = currentFrame+1;
    
    
    bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.frame), CGRectGetMidY(s.frame)));
    s.onConvayorBelt = onBelt;
    
    if(!s.onConvayorBelt){
        if(nextFrame == boxAnimationFrames.count*0.5){
//            NSLog(@"create claw");
            [self createClaw:s givePoint:true];
        }
    }
    
    if(nextFrame >= boxAnimationFrames.count){
        [socksBeingAnimatedIntoBox removeObject:s];        
    }else{
        [s.overlayImageView setImage: [boxAnimationFrames objectAtIndex: nextFrame]];
    }
    
    if(nextFrame > boxAnimationFrames.count*0.75){
        [s.veryTopImageView setImage:[sockPackages objectAtIndex:s.sockId]];
        
        [UIView animateWithDuration:0.5 animations:^void{
            s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, 0);
        } completion:^(BOOL finihed){
            [s setImage:nil];
            
        }];
    }
}

-(void)cleanUpSocksWithClaws {
    for (Sock* s in socks) {
        [self createClaw:s givePoint:false];
    }
}

-(void)createClaw:(Sock*)s givePoint:(BOOL)point{
    Claw* claw = [[Claw alloc] initClawWithSock:s animationFrames: clawAnimationFrames];
    claw.layer.zPosition = SOCK_HIGHEST_LAYER+1;
    [claws addObject:claw];
    [self.view addSubview:claw];
    [claw animateWithSpeed:0.5 withCompletion:^void {
        s.allowMovement = false;
        
        if(point == true){
            [self pointForSock:s];
            [s removeFromSuperview];
            [socks removeObject:s];
        }
        
        [claw removeFromSuperview];
        [claws removeObject:claw];
    }];
}

-(void) pointForSock:(Sock*)s{
    s.allowMovement = false;
    if(s.validSock == true){
        [self gotPoint];
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

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
