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
    UIImage* clawMiddleImage;
    UIImage* clawTopImage;
    UIImage* clawBottomImage;
    
    CGFloat animateWheelSpeed;
}

@end

@implementation GameViewController

@synthesize beltMoveSpeed;
@synthesize animateBeltMoveSpeed;
@synthesize currentGameState;

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
    clawAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_claw"] withYRow:1 withXColumn:1 maxFrames:0];
    wheelFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"anim_wheels"] withYRow:1 withXColumn:4 maxFrames:0];
    sockPackages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockPackage"] withYRow:5 withXColumn:5 maxFrames:5];
    sockMainImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"sockMain"] withYRow:5 withXColumn:5 maxFrames:5];
    
    scoreDigitImages = [self getSplitImagesFromImage:[UIImage imageNamed:@"numbers"] withYRow:1 withXColumn:10 maxFrames:0];
    
    clawMiddleImage = [UIImage imageNamed:@"clawMiddle"];
    clawTopImage = [UIImage imageNamed:@"clawTop"];
    clawBottomImage = [UIImage imageNamed:@"clawBottom"];
    
}

-(void)removeAllSocks{
    for (Sock* sock in socks) {
        [sock removeFromSuperview];
    }
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
    currentGameState = NotPlaying;
    score = 0;
    lives = 3;
    timeToGenerateSock = 1.5;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.06];
    socks = [[NSMutableArray alloc] init];
    claws = [[NSMutableArray alloc] init];
    socksBeingAnimatedIntoBox = [[NSMutableArray alloc] init];

    beltMoveSpeed = 25.0;
    animateBeltMoveSpeed = 0;
    
    animateWheelSpeed = 1;
    timeToAnimateWheels = 0.036;
    animateWheelTimer = 0;
    
    timeForClawAnimation = 0.05;
    clawAnimationTimer = 0;
    
    timeToAnimateScoreValue = 0.04;
    animateScoreValueTimer = 0;
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

-(void) gameFrame:(CADisplayLink*)tmr {
    CGFloat delta = tmr.duration;
    
    if (currentGameState != NotPlaying) {
        
        [self animateBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self updateSocksOnBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self handleAnimateWheel:delta];
        [self handleGenerateSock:delta];
        [self handleClawAnimation: delta];
        [self animateAllSockBoxes];
        
        //TODO remove this system or make it more effiecent
        animateScoreValueTimer += tmr.duration;
        
        if(animateScoreValueTimer >= timeToAnimateScoreValue){
            [self animateScore];
            animateScoreValueTimer = 0;
        }
        
        
        switch (currentGameState) {
            case NotPlaying: break;
            case WarmingUp:
                animateBeltMoveSpeed += delta*8;
                animateWheelSpeed -= delta/4;
                
                if(animateWheelSpeed <= timeToAnimateWheels){
                    animateWheelSpeed = timeToAnimateWheels;
                }
                
                if(animateBeltMoveSpeed >= beltMoveSpeed){
                    animateBeltMoveSpeed = beltMoveSpeed;
                    if(animateWheelSpeed <= timeToAnimateWheels){
                        [self switchGameStateTo:Playing];
                    }
                }
                break;
            case Playing:
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

-(void)startGame{
    [self setupGameValues];
    [self switchGameStateTo:WarmingUp];
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
        [self cleanUpSocksWithClaws];
        [self turnLightsOff];
        [self transitionToGameOver];
        [self switchGameStateTo:NotPlaying];
    }
}


-(void) transitionToGameOver {
    id<GameHandler> strongDelegate = self.gameHandler;
    
    if([strongDelegate respondsToSelector:@selector(switchFromGameToGameOver:withScore:)]){
        [strongDelegate switchFromGameToGameOver:self withScore:score];
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
    
    if(generateSockTimer >= timeToGenerateSock){
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

-(bool) anySocksOnConveyorBelt {
    bool anySockOnBelt = false;
    for (Sock* sock in socks) {
        bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(sock.frame), CGRectGetMidY(sock.frame)));
        if(onBelt == true || sock.onConvayorBelt){
            anySockOnBelt = true;
        }
    }
    return anySockOnBelt;
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
    for(int i = 0; i < socks.count; i++){
        Sock* sock = [socks objectAtIndex:i];
        
        if(sock != nil){
            if(sock.onConvayorBelt == true){
                CGFloat propMoveX = speed/100.0;
                CGFloat moveX = [self propX:propMoveX];
                
                if(sock.frame.origin.x < -sock.frame.size.width){
                    if(!sock.inAPair){
                        [self lostLife];
                    }else{
                        [self pointForSock:sock];
                    }
                    
                    sock.onConvayorBelt = false;
                    //TODO this causes jittering of socks on belt
                    [socks removeObject:sock];
                    
                    [sock removeFromSuperview];
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
        [self switchGameStateTo:Stopping];
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
            [UIView animateWithDuration:0.25 animations:^void{
                s.frame = s.theoreticalFrame;
                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.frame), CGRectGetMidY(s.frame)));
                s.onConvayorBelt = onBelt;
                
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
    NSLog(@"handle intersection");
    for(Sock* ss in socks){
        if(ss != s){
            CGRect f = s.theoreticalFrame;
            if(CGRectIntersectsRect(ss.frame, f) && !(ss.sockId == s.sockId)){
                overlap = true;
                
                CGRect resolveRect = CGRectIntersection(f, ss.frame);
                NSLog(@"Resolve %@ %@ %@", NSStringFromCGRect(f), NSStringFromCGRect(ss.frame), NSStringFromCGRect(resolveRect));
                CGFloat newResolveWidth = resolveRect.size.width < f.size.width/2 ? -resolveRect.size.width : resolveRect.size.width;
                CGFloat newResolveHeight = resolveRect.size.height < f.size.height/2 ? -resolveRect.size.height : resolveRect.size.height;
                CGFloat finalWidth = MIN(fabs(newResolveWidth), fabs(newResolveHeight)) == fabs(newResolveWidth) ? newResolveWidth : 0;
                CGFloat finalHeight = MIN(fabs(newResolveWidth), fabs(newResolveHeight)) == fabs(newResolveHeight) ? newResolveHeight : 0;
                
//                CGRect newDirectionRect = CGRectMake(0, 0, resolveRect.size.width < f.size.width/2 ? -resolveRect.size.width : resolveRect.size.width, resolveRect.size.height < f.size.height/2 ? -resolveRect.size.height : resolveRect.size.height);
                NSLog(@"Res %@", NSStringFromCGSize(CGSizeMake(finalWidth, finalHeight)));
                CGRect newFrame = CGRectMake(f.origin.x+finalWidth, f.origin.y+finalHeight, f.size.width, f.size.height);
//                s.frame = newFrame;
                s.theoreticalFrame = newFrame;
            }
        }
    }
    return overlap == true ? [self handleIntersection:s previousOverlap:true]: prevOverlap;
    
//    return prevOverlap;
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
    
    bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.theoreticalFrame), CGRectGetMidY(s.theoreticalFrame)));
    s.onConvayorBelt = onBelt;
    
    if(nextFrame == boxAnimationFrames.count*0.5){
        [UIView animateWithDuration:0.5 animations:^void{
            s.frame = CGRectMake(s.frame.origin.x, s.frame.origin.y, s.frame.size.width, 0);
        } completion:^(BOOL finished){
            [s setImage:nil];
        }];
    }
    
    if(nextFrame >= boxAnimationFrames.count){
        s.animatingIntoBox = false;
        [socksBeingAnimatedIntoBox removeObject:s];
        
        if(!s.onConvayorBelt){
            [self createClaw:s givePoint:true];
        }
    }else{
        s.animatingIntoBox = true;
        [s.overlayImageView setImage: [boxAnimationFrames objectAtIndex: nextFrame]];
    }
    
    if(nextFrame > boxAnimationFrames.count*0.75){
        [s.veryTopImageView setImage:[sockPackages objectAtIndex:s.sockId]];
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
        if(point == true){
            [self pointForSock:s];
        }
        
        [s removeFromSuperview];
        [socks removeObject:s];
        
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
