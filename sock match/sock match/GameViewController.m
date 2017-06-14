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
    
    CGRect pairSocksConvayorBelt;
    CGFloat pairSocksBeltMoveSpeed;
    
    UILabel* scoreLabel;
    
    UIView* greenLight;
    UIView* redLight;
    
    UILabel* tutorialLabel;
    UILabel* bottomTutorialLabel;
    
    int score;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithRed:0.16862751 green:0.168627451 blue:0.168627451 alpha:1];
    
//    CGFloat width = [self propX:0.1];
//    UIImage* pattern = [self scaleImage:[UIImage imageNamed:@"floor"] toSize:CGSizeMake(width, width)];
//    UIColor* bg = [UIColor colorWithPatternImage:pattern];
//    self.view.backgroundColor = bg;
    
    score = 0;
    timeToGenerateSock = 1.5;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.06];
    socks = [[NSMutableArray alloc] init];
    convayorBeltRect = [self propToRect:CGRectMake(0, 0.15, 1, 0.3)];
    beltMoveSpeed = 20.0;
    
    CGRect pkImageRect = [self propToRect:CGRectMake(1, 1, 0.2, 0)];
    CGRect pairSocksConvayorBeltMetaRect = [self propToRect:CGRectMake(0, 1, 1, 0)];
    
    pairSocksConvayorBelt = CGRectMake(pairSocksConvayorBeltMetaRect.origin.x, pairSocksConvayorBeltMetaRect.origin.y-pkImageRect.size.width, pairSocksConvayorBeltMetaRect.size.width-pkImageRect.size.width, pkImageRect.size.width);
    
//    pairSocksConvayorBelt =
    
    NSLog(@"RE %@", NSStringFromCGRect(pairSocksConvayorBelt));
    pairSocksBeltMoveSpeed = 20.0;
    
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameFrame:)];
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
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
    
    
    [self scaleImage:[UIImage imageNamed:@"belt_3"] toSize:CGSizeMake(convayorBeltRect.size.width, convayorBeltRect.size.height)];
    NSArray *imagesArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"belt_2"], [UIImage imageNamed:@"belt_1"], [UIImage imageNamed:@"belt_0"], nil];
//    NSArray *imagesArray = [NSArray arrayWithObjects:[self scaleImage:[UIImage imageNamed:@"belt_3"] toSize:CGSizeMake(convayorBeltRect.size.width, convayorBeltRect.size.height)], [self scaleImage:[UIImage imageNamed:@"belt_2"] toSize:CGSizeMake(convayorBeltRect.size.width, convayorBeltRect.size.height)], [self scaleImage:[UIImage imageNamed:@"belt_1"] toSize:CGSizeMake(convayorBeltRect.size.width, convayorBeltRect.size.height)], [self scaleImage:[UIImage imageNamed:@"belt_0"] toSize:CGSizeMake(convayorBeltRect.size.width, convayorBeltRect.size.height)], nil];
    
    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame: convayorBeltRect];
    animatedImageView.animationImages = imagesArray;
    animatedImageView.animationDuration = 1.5f;
    animatedImageView.animationRepeatCount = 0;
//    animatedImageView.layer.borderWidth = 2;
//    animatedImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    animatedImageView.contentMode = UIViewContentModeScaleAspectFill;
    animatedImageView.layer.magnificationFilter = kCAFilterNearest;
    [animatedImageView startAnimating];
    [self.view addSubview: animatedImageView];
    
    
    UIImageView* pairSockBelt = [[UIImageView alloc] initWithFrame: pairSocksConvayorBelt];
    pairSockBelt.animationImages = imagesArray;
    pairSockBelt.animationDuration = 2.0f;
    pairSockBelt.animationRepeatCount = 0;
//    pairSockBelt.layer.borderWidth = 2;
//    pairSockBelt.layer.borderColor = [UIColor whiteColor].CGColor;
    
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

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
//    CGSize scaledSize = newSize;
//    float scaleFactor = 1.0;
//    if( image.size.width > image.size.height ) {
//        scaleFactor = image.size.width / image.size.height;
//        scaledSize.width = newSize.width;
//        scaledSize.height = newSize.height;// / scaleFactor;
//    }
//    else {
//        scaleFactor = image.size.height / image.size.width;
//        scaledSize.height = newSize.height;
//        scaledSize.width = newSize.width;// / scaleFactor;
//    }
    
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 1.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, newSize.width, newSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(void) gameFrame:(CADisplayLink*)tmr {
    [self updateSocksOnBeltWithDelta:tmr.duration];
    
    generateSockTimer += tmr.duration;
    
    if(generateSockTimer >= timeToGenerateSock){
        [self generateSock];
        generateSockTimer = 0;
    }
}

-(void) updateSocksOnBeltWithDelta:(CGFloat)delta {
    for(int i = 0; i < socks.count; i++){
        Sock* sock = [socks objectAtIndex:i];
        
        if(sock != nil){
            if(sock.onConvayorBelt == true){
                CGFloat propMoveX = beltMoveSpeed/100.0;
                CGFloat moveX = [self propX:propMoveX];
                
//                if(!sock.inAPair){
                    sock.frame = CGRectOffset(sock.frame, -moveX*delta, 0);
                    
//                    if(sock.mainSockInPair && sock.otherSockInPair != nil){
//                        sock.otherSockInPair.frame = CGRectOffset(sock.otherSockInPair.frame, -moveX*delta, 0);
//                    }
                    
                    if(sock.frame.origin.x < -sock.frame.size.width){
                        
                        [sock removeFromSuperview];
                        [socks removeObject:sock];
                        
//                        if(sock.mainSockInPair && sock.otherSockInPair != nil){
//                            [sock.otherSockInPair removeFromSuperview];
//                            [socks removeObject:sock.otherSockInPair];
//                        }
                        
//                        if(!sock.inAPair){
                            redLight.backgroundColor = [UIColor redColor];
                            [self performSelector:@selector(setBackgroundColorClear:) withObject:redLight afterDelay:1];
                            NSLog(@"Lose.");
//                        }
                    }
//                }
            }else if(sock.onPairConvayorBelt == true){
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
        bool onBelt = CGRectContainsPoint(convayorBeltRect, p);
        s.onConvayorBelt = onBelt;
        
        if(!onBelt){
            bool onPairBelt = CGRectContainsPoint(pairSocksConvayorBelt, p);
            s.onPairConvayorBelt = onPairBelt;
        }
        // does not have to be out of the best to check for pairs (directly match on the belt)
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
                [sock setImage:[UIImage imageNamed:[NSString stringWithFormat:@"sock%ipackage", sock.sockId]]];
                
                sock.inAPair = otherSock.inAPair = true;
                sock.mainSockInPair = true;
                
                sock.otherSockInPair = otherSock;
                otherSock.otherSockInPair = sock;
                otherSock.layer.borderColor = [UIColor orangeColor].CGColor;
                
                // TODO make these constants for the three sizes (here and above)
//                CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:sock.sockSize]/10.0];
//
//                otherSock.center = CGPointMake(sock.center.x-matchedPairPositionOffset, sock.center.y+matchedPairPositionOffset); // set center
            }
        }
    }
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
