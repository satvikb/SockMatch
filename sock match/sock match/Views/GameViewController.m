//
//  GameViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameViewController.h"
#import "Functions.h"

#define SOCK_HIGHEST_LAYER (50)

@interface GameViewController () {
    CGFloat timeToGenerateSock;
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
    
    NSMutableArray <UIImageView*>* lifeLights;
    
    int score;
    int currentAnimatingScore;
    int lives;
    
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
    
    //TODO put these two in one image
    UIImage* lifeLightOff;
    UIImage* lifeLightOn;
}

@end

@implementation GameViewController

@synthesize sockMainImages;
@synthesize sockPackages;
@synthesize scoreDigitImages;

@synthesize boxAnimationFrames;
@synthesize wheelFrames;
@synthesize clawAnimationFrames;
@synthesize forkLiftAnimationFrames;
@synthesize emissionAnimationFrames;

@synthesize beltMoveSpeed;
@synthesize animateBeltMoveSpeed;
@synthesize currentGameState;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"GAME VIEW");
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
    forkLiftAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"forklift"] withYRow:2 withXColumn:1 maxFrames:0];
    emissionAnimationFrames = [self getSplitImagesFromImage:[UIImage imageNamed:@"emissions"] withYRow:5 withXColumn:1 maxFrames:0];
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
    forklifts = [[NSMutableArray alloc] init];
    socksBeingAnimatedIntoBox = [[NSMutableArray alloc] init];

    beltMoveSpeed = 25.0;
    animateBeltMoveSpeed = 0;
    
    animateWheelSpeed = 1;
    timeToAnimateWheels = 0.036;
    animateWheelTimer = 0;
    
    timeForClawAnimation = 0.05;
    clawAnimationTimer = 0;
    
    timeForForkliftAnimation = 0.25;
    forkliftAnimationTimer = 0;
    
    timeToAnimateScoreValue = 0.04;
    animateScoreValueTimer = 0;
}

-(void)createUI {
    
    lifeLights = [[NSMutableArray alloc] init];
    conveyorBeltRect = [self propToRect:CGRectMake(-0.1, 0.15, 1.1, 0.3)];

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

-(void) gameFrame:(CADisplayLink*)tmr {
    CGFloat delta = tmr.duration;
    
    if (currentGameState != NotPlaying) {
        
        [self animateBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self updateSocksOnBeltWithSpeed:animateBeltMoveSpeed delta:delta];
        [self handleAnimateWheel:delta];
        [self handleGenerateSock:delta];
        [self handleClawAnimation: delta];
        [self handleForkliftAnimation:delta];
        [self animateAllSockBoxes];
        
        //TODO remove this system or make it more effiecent
        animateScoreValueTimer += tmr.duration;
        
        if(animateScoreValueTimer >= timeToAnimateScoreValue){
//            int dd = abs(currentAnimatingScore-score);
//            int d = dd/4;
//            int ad = dd/d;
//            int diff = ad < d ? 1 : ad;
//            NSLog(@"D %i", diff);
            int diff = 1;
            [self animateScore: diff];
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
        bool onBelt = CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX([sock getCoreRect]), CGRectGetMidY([sock getCoreRect])));
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
                        [self lostLife];
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

-(void) gotPoint {
    timeToGenerateSock = timeToGenerateSock >= 1 ? timeToGenerateSock -= 0.025 : 1;
    
    score += 1;
}

-(void) animateScore:(int)times {
    if(currentAnimatingScore != score){
        for (int i = 0; i < times; i++) {
            currentAnimatingScore = currentAnimatingScore < score ? currentAnimatingScore+1 : currentAnimatingScore-1;
            [self setScoreImages:currentAnimatingScore];
        }
    }
}

//TODO allow more digits than 4
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
    if(lives >= 3){
        lives = 3;
    }
    
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
    Sock* newSock = [[Sock alloc] initWithFrame:pos width: width sockSize: size sockId: sockId image: sockImage onBelt:onBelt extraPropTouchSpace:0.75];
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
            
//            [self checkPairsWithSock:s];
        }
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            bool onBelt = CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX([s getCoreRect]), CGRectGetMidY([s getCoreRect])));
            s.onConvayorBelt = onBelt;
        }
        
        if([self handleIntersection:s previousOverlap:false direction:0 recursionCount:0]){
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
                s.frame = s.theoreticalFrame;
                s.theoreticalFrame = s.frame;
            } completion:^(BOOL completion){
                bool onBelt = CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX([s getCoreRect]), CGRectGetMidY([s getCoreRect])));
                s.onConvayorBelt = onBelt;
//                [self checkPairsWithSock:s];
            }];
        }
    }];
    
    [self.view addSubview:newSock];
    [socks addObject:newSock];
}

#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

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
    UIView* test = [[UIView alloc] initWithFrame: frame];
    test.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:0.6];
    test.layer.zPosition = 1000;
    [self.view addSubview:test];
    [self performSelector:@selector(removeFromView:) withObject:test afterDelay:2];
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
    otherSock.layer.zPosition= 150;
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
    
    bool onBelt = CGRectContainsPoint(conveyorBeltRect, CGPointMake(CGRectGetMidX(s.theoreticalFrame), CGRectGetMidY(s.theoreticalFrame)));
    s.onConvayorBelt = onBelt;
    
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

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
