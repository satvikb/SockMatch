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
@synthesize sockOneTouchMoveBlock;
@synthesize sockTwoTouchMoveBlock;

@synthesize tutorialText;

-(id)initWithScreenFrame:(CGRect)frame andSockImage:(UIImage*)sockImage{
    self = [super initWithFrame:frame];
    
    NSLog(@"creating tutorial");
    Sock* s1 = [[Sock alloc] initWithFrame:[self propToRect:CGRectMake(1, [Functions randFromMin:0.2 toMax:0.4], 0, 0)].origin width:[self propX:[Functions propSizeFromSockSize:Medium]] sockSize:Medium sockId:0 image: sockImage onBelt:true extraPropTouchSpace:0.75];
    
    [s1 setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            s.layer.zPosition = 50;
        }
    }];
    
    [s1 setTouchMovedBlock:^void (Sock* s, CGPoint p, CGPoint oldPos) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            self->sockOneTouchMoveBlock(s);
            
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
        }
    }];
    
    [s1 setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            self->sockOneTouchEndBlock(s);
        }
    }];
    
    Sock* s2 = [[Sock alloc] initWithFrame:[self propToRect:CGRectMake(1, [Functions randFromMin:0.2 toMax:0.4], 0, 0)].origin width:[self propX:[Functions propSizeFromSockSize:Medium]] sockSize:Medium sockId:0 image: sockImage onBelt:true extraPropTouchSpace:0.75];
    
    [s2 setTouchBeganBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            //                [self decreaseSockLayerPositions];
            s.layer.zPosition = 50;

        }
    }];
    
    [s2 setTouchMovedBlock:^void (Sock* s, CGPoint p, CGPoint oldPos) {
        if(s.allowMovement){
            s.onConvayorBelt = false;
            
            self->sockTwoTouchMoveBlock(s);
            
            CGPoint delta = CGPointMake(p.x-oldPos.x, p.y-oldPos.y);
            
            CGRect newFrame = CGRectOffset( s.theoreticalFrame, delta.x, delta.y );
            
            s.frame = newFrame;
            s.theoreticalFrame = newFrame;
        }
    }];
    
    [s2 setTouchEndedBlock:^void (Sock* s, CGPoint p) {
        if(s.allowMovement){

        }
    }];
    
    self.sockOne = s1;
    self.sockTwo = s2;
    [self addSubview:sockOne];
    [self addSubview:sockTwo];
    
    tutorialText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.05, 1, .9, 0.1)]];
    tutorialText.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:26]];
    tutorialText.text = @"welcome to sock factory!";
    tutorialText.textAlignment = NSTextAlignmentCenter;
    tutorialText.adjustsFontSizeToFitWidth = true;
//    tutorialText.layer.borderColor = [UIColor blackColor].CGColor;
//    tutorialText.layer.borderWidth = 2;
    tutorialText.numberOfLines = 0;
    [self addSubview:tutorialText];
    
    return self;
}

-(void)animateSockOneToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed {
    //d = rt
    CGFloat animateTime = fabs([sockOne getCoreRect].origin.x - xPos)/[self propX:beltMoveSpeed];
    tutorialState = AnimatingSockOne;
    
    [UIView animateWithDuration:animateTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
        CGRect core = CGRectMake(xPos, [self->sockOne getCoreRect].origin.y, 0, 0);
        [self->sockOne setRectFromCoreRect:core];
        [self->sockOne setTheoreticalRectFromCoreTheoreticalRect:core];
    } completion:^(BOOL finished){
        self->tutorialText.text = @"move socks from the belt to the matching area";
        self->tutorialState = WaitingToMoveSockOne;
        self->sockOne.allowMovement = true;
        self->sockOne.theoreticalFrame = self->sockOne.frame;
        self->animateSockOneCompleteBlock(self->sockOne);
    }];
}

-(void)animateSockTwoToX:(CGFloat)xPos withBeltMoveSpeed:(CGFloat)beltMoveSpeed {
    //d = rt
    CGFloat animateTime = fabs([sockTwo getCoreRect].origin.x - xPos)/[self propX:beltMoveSpeed];
    tutorialState = AnimatingSockTwo;
    
    [UIView animateWithDuration:animateTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^void{
        CGRect core = CGRectMake(xPos, [self->sockTwo getCoreRect].origin.y, 0, 0);
        [self->sockTwo setRectFromCoreRect:core];
        [self->sockTwo setTheoreticalRectFromCoreTheoreticalRect:core];
    } completion:^(BOOL finished){
        self->tutorialText.text = @"combine socks of similar colors to form a package";
        self->tutorialState = WaitingToMoveSockTwo;
        self->sockTwo.allowMovement = true;
        self->sockTwo.theoreticalFrame = self->sockTwo.frame;
        self->animateSockTwoCompleteBlock(self->sockTwo);
    }];
}

-(void)animateTutorialLabelIn {
    [UIView animateWithDuration:0.5 animations:^void{
        self->tutorialText.frame = [self propToRect:CGRectMake(0.05, 0.75, .9, 0.1)];
    }];
}

-(void)animateTutorialLabelOutAndRemoveTutorialView {
    [UIView animateWithDuration:0.5 animations:^void{
        self->tutorialText.frame = [self propToRect:CGRectMake(0.05, 1, .9, 0.1)];
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

-(void)focusOnRect:(CGRect)rect withLabels:(NSArray<UILabel*>*)labels touchBlock:(void (^)(void))touched{
    FocusOnRect* focus = [[FocusOnRect alloc] initWithRectToFocusOn:rect withLabels:labels screenSize:UIScreen.mainScreen.bounds.size];
    focus.layer.zPosition = 151;
    __unsafe_unretained typeof(FocusOnRect*) weak = focus;
    
    [focus setTouchBlock:^void{
        if(![weak showNextLabel]){
            touched();
            
            [weak hide:0 withDuration:0.5 withCompletion:^(BOOL completed){
                [weak removeFromSuperview];
            }];
        }
    }];
    
    [focus show:0.3 withDuration:0.5 withCompletion:^(BOOL completed){
        
    }];
    [self addSubview:focus];
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
