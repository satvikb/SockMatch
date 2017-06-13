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
    
    UILabel* scoreLabel;
    
    int score;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.16862751 green:0.168627451 blue:0.168627451 alpha:1];
    
    score = 0;
    timeToGenerateSock = 1.5;
    generateSockTimer = 0;
    sockMatchThreshold = [self propX:0.06];
    socks = [[NSMutableArray alloc] init];
    convayorBeltRect = [self propToRect:CGRectMake(0, 0.15, 1, 0.3)];
    beltMoveSpeed = 20.0;
    
    gameTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(gameFrame:)];
    [gameTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    
    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.05, 1, 0.1)]];
    scoreLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    scoreLabel.layer.borderWidth = 2;
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.font = [UIFont fontWithName:@"Helvetica" size:26];
    scoreLabel.text = @"0";
    [self.view addSubview:scoreLabel];
//    CGRect testSockFrame = [self propToRect:CGRectMake(0.2, 0.5, 0.2, 0)];
//    [self createSockAtPos:testSockFrame.origin width:testSockFrame.size.width sockId:0 imageName:@"sock0" onBelt:false];
    
    UIView* belt = [[UIView alloc] initWithFrame:convayorBeltRect];
    belt.layer.borderColor = [UIColor whiteColor].CGColor;
    belt.layer.borderWidth = 2;
    [self.view addSubview:belt];
    
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
                
                if(!sock.inAPair || sock.mainSockInPair){
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
                                score += 1;
                                scoreLabel.text = [NSString stringWithFormat:@"%i", score];
                            }
                        }else{
                            NSLog(@"LOSE");
                        }
                        
                    }
                }
            }
        }else{
            NSLog(@"NO SOCK WHILE UPDATING BELT");
        }
    }
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
    }];
    
    [newSock setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        bool onBelt = CGRectContainsPoint(convayorBeltRect, p);
        s.onConvayorBelt = onBelt;
        
        // does not have to be out of the best to check for pairs (directly match on the belt)
//        if(onBelt == false){
            // check for sock pairs
            [self checkPairsWithSock:s];
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
                [self.view insertSubview:sock aboveSubview:otherSock];
                
                sock.inAPair = otherSock.inAPair = true;
                sock.mainSockInPair = true;
                
                sock.otherSockInPair = otherSock;
                otherSock.otherSockInPair = sock;
                otherSock.layer.borderColor = [UIColor orangeColor].CGColor;
                
                // TODO make these constants for the three sizes (here and above)
                CGFloat matchedPairPositionOffset = [self propX:[Functions propSizeFromSockSize:sock.sockSize]/10.0];
                
                otherSock.center = CGPointMake(sock.center.x-matchedPairPositionOffset, sock.center.y+matchedPairPositionOffset); // set center
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
