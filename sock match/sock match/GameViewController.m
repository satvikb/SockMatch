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
    
    CGRect pairSocksConvayorBelt;
    CGFloat pairSocksBeltMoveSpeed;
    
    UILabel* scoreLabel;
    
    UIView* greenLight;
    UIView* redLight;
    
    UILabel* tutorialLabel;
    UILabel* bottomTutorialLabel;
    
    int score;
    
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
    
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameFrame:)];
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)setupGameValues {
    score = 0;
    timeToGenerateSock = 1.5;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.06];
    socks = [[NSMutableArray alloc] init];
    convayorBeltRect = [self propToRect:CGRectMake(0, 0.15, 1, 0.3)];
    beltMoveSpeed = 20.0;
    
    timeToAnimateWheels = 0.05;
    animateWheelTimer = 0;
    
    CGRect pkImageRect = [self propToRect:CGRectMake(1, 1, 0.2, 0)];
    CGRect pairSocksConvayorBeltMetaRect = [self propToRect:CGRectMake(0, 1, 1, 0)];
    
    pairSocksConvayorBelt = CGRectMake(pairSocksConvayorBeltMetaRect.origin.x, pairSocksConvayorBeltMetaRect.origin.y-pkImageRect.size.width, pairSocksConvayorBeltMetaRect.size.width-pkImageRect.size.width, pkImageRect.size.width);
    pairSocksBeltMoveSpeed = 20.0;
    
}

-(void)createUI {
    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.15, 0.05, 0.7, 0.1)]];
    scoreLabel.layer.borderColor = [UIColor blackColor].CGColor;
    scoreLabel.layer.borderWidth = 2;
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor blackColor];
    scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:26];
    scoreLabel.text = @"0";
    [self.view addSubview:scoreLabel];
    
    CGSize lightSize = [self propToRect:CGRectMake(0, 0.05, 0.15, 0.1)].size;
    
    CGPoint redLightPos = [self propToRect:CGRectMake(0, 0.05, 0, 0)].origin;
    redLight = [[UIView alloc] initWithFrame: CGRectMake(redLightPos.x, redLightPos.y, lightSize.width, lightSize.width)];
    redLight.layer.cornerRadius = lightSize.width/2;
    redLight.backgroundColor = [UIColor clearColor];
    [self.view addSubview:redLight];
    
    CGPoint greenLightPos = [self propToRect:CGRectMake(0.85, 0.05, 0, 0)].origin;
    greenLight = [[UIView alloc] initWithFrame: CGRectMake(greenLightPos.x, greenLightPos.y, lightSize.width, lightSize.width)];
    greenLight.layer.cornerRadius = lightSize.width/2;
    greenLight.backgroundColor = [UIColor clearColor];
    [self.view addSubview:greenLight];
    
    
    tutorialLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.45, 1, 0.075)]];
    tutorialLabel.text = @"match socks together based on style and size";
    tutorialLabel.textAlignment = NSTextAlignmentCenter;
    //    tutorialLabel.layer.borderColor = [UIColor blackColor].CGColor;
    //    tutorialLabel.layer.borderWidth = 2;
    [self.view addSubview:tutorialLabel];
    
    CGRect btmTutFrame = [self propToRect:CGRectMake(0, 1, 1, 0.075)];
    bottomTutorialLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, btmTutFrame.origin.y-pairSocksConvayorBelt.size.height-btmTutFrame.size.height, btmTutFrame.size.width, btmTutFrame.size.height)];
    bottomTutorialLabel.text = @"put packaged socks down here";
    bottomTutorialLabel.textAlignment = NSTextAlignmentCenter;
    //    bottomTutorialLabel.layer.borderColor = [UIColor blackColor].CGColor;
    //    bottomTutorialLabel.layer.borderWidth = 2;
    [self.view addSubview:bottomTutorialLabel];
    
    [self performSelector:@selector(removeFromView:) withObject:tutorialLabel afterDelay:15];
    [self performSelector:@selector(removeFromView:) withObject:bottomTutorialLabel afterDelay:25];
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
    [self createConveyorBeltWheels:bottomBeltWheelsRect imageArray:bottomConveyorBeltWheels forArray:bottomConveyorBeltWheelsFrames];
    
    CGRect topBeltWheelsRect = [self propToRect:CGRectMake(-0.05, 0.1375, 1, 0.025)];
    topConveyorBeltWheels = [[NSMutableArray alloc] init];
    topConveyorBeltWheelsFrames = [[NSMutableArray alloc] init];
    
    [self createConveyorBeltWheels:topBeltWheelsRect imageArray:topConveyorBeltWheels forArray:topConveyorBeltWheelsFrames];
    
    
    
    
    CGRect pkImageRect = [self propToRect:CGRectMake(1, 1, 0.2, 0)];
    UIImageView* pairSockBelt = [[UIImageView alloc] initWithFrame: pairSocksConvayorBelt];
    //    pairSockBelt.layer.borderWidth = 2;
    //    pairSockBelt.layer.borderColor = [UIColor whiteColor].CGColor;
    [pairSockBelt setImage:[UIImage imageNamed:@"beltTile"]];
    pairSockBelt.clipsToBounds = true;
    pairSockBelt.contentMode = UIViewContentModeScaleAspectFill;
    pairSockBelt.layer.magnificationFilter = kCAFilterNearest;
    [pairSockBelt startAnimating];
    [self.view addSubview: pairSockBelt];
    UIImageView* pairBeltPackageImage = [[UIImageView alloc] initWithFrame: CGRectMake(pkImageRect.origin.x-pkImageRect.size.width, pkImageRect.origin.y-pkImageRect.size.width, pkImageRect.size.width, pkImageRect.size.width)];
    pairBeltPackageImage.contentMode = UIViewContentModeScaleAspectFill;
    pairBeltPackageImage.layer.magnificationFilter = kCAFilterNearest;
    [pairBeltPackageImage setImage:[UIImage imageNamed:@"sock1package"]];
    [self.view addSubview:pairBeltPackageImage];
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
//        beltTile.layer.borderWidth = 1;
//        beltTile.layer.borderColor = [UIColor greenColor].CGColor;
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
        [self generateSock];
        generateSockTimer = 0;
    }
    
    if(animateWheelTimer >= timeToAnimateWheels){
        [self animateWheels:bottomConveyorBeltWheels withFrames:bottomConveyorBeltWheelsFrames];
        [self animateWheels:topConveyorBeltWheels withFrames:topConveyorBeltWheelsFrames];
        
        animateWheelTimer = 0;
    }
}


-(void)animateBelt:(CGFloat)delta {
    //    for(int i = 0; i < )
    
    for (UIImageView* img in conveyorBeltTiles) {
        CGFloat propMoveX = beltMoveSpeed/100.0;
        CGFloat moveX = [self propX:propMoveX];
        CGFloat moveDelta = -moveX*delta;
        
        if(img.frame.origin.x <= -img.frame.size.width){
            CGRect f = img.frame;
            CGFloat overflow = img.frame.origin.x - (-img.frame.size.width);
            
            f.origin.x = _beltImagesSideExtra-img.frame.size.width+overflow;//+(img.frame.origin.x-img.frame.size.width);
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
//            bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(sock.frame), CGRectGetMidY(sock.frame)));
//            sock.onConvayorBelt = onBelt;
            
            if(sock.onConvayorBelt == true){
                if(sock.inAPair == false){
                    CGFloat propMoveX = beltMoveSpeed/100.0;
                    CGFloat moveX = [self propX:propMoveX];
//                    CGFloat moveDelta = -moveX*delta;
                    
//                    sock.frame = CGRectOffset(sock.frame, moveDelta, 0);
                    sock.frame = CGRectOffset(sock.frame, -moveX*delta, 0);
//                    NSLog(@"d %f", delta);
                    
                    if(sock.frame.origin.x < -sock.frame.size.width){
                        
                        [sock removeFromSuperview];
                        [socks removeObject:sock];
                        
                        redLight.backgroundColor = [UIColor redColor];
                        [self performSelector:@selector(setBackgroundColorClear:) withObject:redLight afterDelay:0.05];
                    }
                }
            }
                else if(sock.onPairConvayorBelt == true){
                CGFloat propMoveX = pairSocksBeltMoveSpeed/100.0;
                CGFloat moveX = [self propX:propMoveX];
                    
//                if(sock.inAPair){//} || sock.mainSockInPair){
                    sock.frame = CGRectOffset(sock.frame, -moveX*delta, 0);
                    
                    if(sock.mainSockInPair && sock.otherSockInPair != nil){
                        sock.otherSockInPair.frame = CGRectOffset(sock.otherSockInPair.frame, -moveX*delta, 0);
                    }
                    
                    if(sock.frame.origin.x < -sock.frame.size.width){
                        
                        [sock removeFromSuperview];
                        [socks removeObject:sock];
                        
                        if(sock.mainSockInPair && sock.otherSockInPair != nil){
                            [sock.otherSockInPair removeFromSuperview];
                            [socks removeObject:sock.otherSockInPair];
                        }
                        
                        if(sock.inAPair == true){
                            if(sock.mainSockInPair == true){
                                NSLog(@"POINT!!!!");
                                
                                timeToGenerateSock = timeToGenerateSock >= 1 ? timeToGenerateSock -= 0.025 : 1;
                                greenLight.backgroundColor = [UIColor greenColor];
                                [self performSelector:@selector(setBackgroundColorClear:) withObject:greenLight afterDelay:1];
                                
                                score += 1;
                                scoreLabel.text = [NSString stringWithFormat:@"%i", score];
                            }
                        }else{
                            redLight.backgroundColor = [UIColor redColor];
                            [self performSelector:@selector(setBackgroundColorClear:) withObject:redLight afterDelay:1];
                            NSLog(@"Single sock in pair belt!");
                        }
                    }
//                }
            }
        }else{
            NSLog(@"NO SOCK WHILE UPDATING BELT");
        }
    }
}

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
        s.onPairConvayorBelt = false;
    }];
    
    [newSock setTouchMovedBlock:^void (Sock* s, CGPoint p) {
        s.onConvayorBelt = false;
        s.onPairConvayorBelt = false;
        
        if((!s.inAPair || s.mainSockInPair) && s.otherSockInPair != nil){
            CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:s.sockSize]/10.0];
            s.otherSockInPair.center = CGPointMake(s.center.x-matchedPairPositionOffset, s.center.y+matchedPairPositionOffset); // set center
        }
        
        [self checkPairsWithSock:s];
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        
        bool onBelt = CGRectContainsPoint(convayorBeltRect, CGPointMake(CGRectGetMidX(s.frame), CGRectGetMidY(s.frame)));
        s.onConvayorBelt = onBelt;
        
        bool onPairBelt = CGRectContainsPoint(pairSocksConvayorBelt, p);
        s.onPairConvayorBelt = onPairBelt;
        
        // does not have to be out of the best to check for pairs (in case of directly matched on the belt)
//        if(onBelt == false){
            // check for sock pairs
//            [self checkPairsWithSock:s];
//        }
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
//                [self.view insertSubview:sock aboveSubview:otherSock];
                [otherSock removeFromSuperview];
                [socks removeObject:otherSock];
                [sock setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sock%ipackage", sock.sockId]]];
                
                sock.inAPair = otherSock.inAPair = true;
                sock.mainSockInPair = true;
                
                sock.otherSockInPair = otherSock;
                otherSock.otherSockInPair = sock;
                otherSock.layer.borderColor = [UIColor orangeColor].CGColor;
                
                // TODO make these constants for the three sizes (here and above)
//                CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:sock.sockSize]/10.0];
//                otherSock.center = CGPointMake(sock.center.x-matchedPairPositionOffset, sock.center.y+matchedPairPositionOffset); // set center
            }
        }
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

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
