//
//  TutorialView.m
//  sock match
//
//  Created by Satvik Borra on 6/30/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "TutorialView.h"

@implementation TutorialView

@synthesize tutorialState;
@synthesize sockOne;
@synthesize sockTwo;

@synthesize animateSockOneCompleteBlock;
@synthesize animateSockTwoCompleteBlock;
@synthesize sockOneTouchEndBlock;
@synthesize sockTwoTouchMoveBlock;

-(id)initWithScreenFrame:(CGRect)frame andSockImage:(UIImage*)sockImage{
    self = [super initWithFrame:frame];
    
    NSLog(@"creating tutorial");
    Sock* s1 = [[Sock alloc] initWithFrame:[self propToRect:CGRectMake(1, [Functions randFromMin:0.2 toMax:0.4], 0, 0)].origin width:[self propX:[Functions propSizeFromSockSize:Medium]] sockSize:Medium sockId:0 image: sockImage onBelt:true extraPropTouchSpace:0.75];
    
    [s1 setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            s.layer.zPosition = 50;
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
                s.coreImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL completed){
                
            }];
        }
    }];
    
    [s1 setTouchMovedBlock:^void (Sock* s, CGPoint p, CGPoint oldPos) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            
            //TODO collisions
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
        }
    }];
    
    [s1 setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            sockOneTouchEndBlock(s);
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
                s.coreImageView.transform = CGAffineTransformIdentity;//CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL completed){
                
            }];
        }
    }];
    
    Sock* s2 = [[Sock alloc] initWithFrame:[self propToRect:CGRectMake(1, [Functions randFromMin:0.2 toMax:0.4], 0, 0)].origin width:[self propX:[Functions propSizeFromSockSize:Medium]] sockSize:Medium sockId:0 image: sockImage onBelt:true extraPropTouchSpace:0.75];
    
    [s2 setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            //                [self decreaseSockLayerPositions];
            s.layer.zPosition = 50;
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
                s.coreImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL completed){
                
            }];
        }
    }];
    
    [s2 setTouchMovedBlock:^void (Sock* s, CGPoint p, CGPoint oldPos) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            
            sockTwoTouchMoveBlock(s);
            
            //TODO collisions
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
        }
    }];
    
    [s2 setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
                s.coreImageView.transform = CGAffineTransformIdentity;//CGAffineTransformMakeScale(1.2, 1.2);
            } completion:^(BOOL completed){
                
            }];
        }
    }];
    
    self.sockOne = s1;
    self.sockTwo = s2;
    [self addSubview:sockOne];
    [self addSubview:sockTwo];
    return self;
}

-(void)animateSockOneToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed {
    //d = rt
    CGFloat animateTime = fabs([sockOne getCoreRect].origin.x - xPos)/[self propX:beltMoveSpeed];
    tutorialState = AnimatingSockOne;
    
    [UIView animateWithDuration:animateTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
        CGRect core = CGRectMake(xPos, [sockOne getCoreRect].origin.y, 0, 0);
        [sockOne setRectFromCoreRect:core];
        [sockOne setTheoreticalRectFromCoreTheoreticalRect:core];
    } completion:^(BOOL finished){
        tutorialState = WaitingToMoveSockOne;
        sockOne.allowMovement = true;
        //TODO figure out why
        sockOne.theoreticalFrame = sockOne.frame;
        animateSockOneCompleteBlock(sockOne);
    }];
}

-(void)animateSockTwoToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed {
    //d = rt
    CGFloat animateTime = fabs([sockTwo getCoreRect].origin.x - xPos)/[self propX:beltMoveSpeed];
    tutorialState = AnimatingSockTwo;
    
    [UIView animateWithDuration:animateTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
        CGRect core = CGRectMake(xPos, [sockTwo getCoreRect].origin.y, 0, 0);
        [sockTwo setRectFromCoreRect:core];
        [sockTwo setTheoreticalRectFromCoreTheoreticalRect:core];
    } completion:^(BOOL finished){
        tutorialState = WaitingToMoveSockTwo;
        sockTwo.allowMovement = true;
        //TODO figure out why
        sockTwo.theoreticalFrame = sockTwo.frame;
        animateSockTwoCompleteBlock(sockTwo);
    }];
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
