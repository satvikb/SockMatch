//
//  Forklift.m
//  sock match
//
//  Created by Satvik Borra on 6/28/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Forklift.h"

@implementation Forklift {
    bool forkliftFacesRight;
    
    NSMutableArray<UIImage*>* forkliftAnimationFrames;
    NSInteger currentForkliftFrame;
    
    NSMutableArray<UIImage*>* emissionAnimationFrames;
    NSInteger currentEmissionFrame;
    
    NSMutableArray<UIImage*>* wheelAnimationFrames;
    NSInteger currentWheelFrame;
    
    UIImageView* emissionImageView;
    
    UIImageView* wheelTop;
    UIImageView* wheelBottom;
    
    bool currentlyAnimating;
    CGSize screenSize;
    
    CGFloat forkliftForkLength;
    CGFloat pickupPadding;
    
    CGFloat pickupScaleExtra;
    
    Sock* sock;
}

-(id)initWithSock:(Sock*)s forkliftAnimationFrames:(NSMutableArray<UIImage*>*)forkliftAnimation emissionAnimationFrames:(NSMutableArray<UIImage*>*)emissionAnimation wheelAnimationFrames:(NSMutableArray<UIImage*>*)wheelAnimation{
    screenSize = UIScreen.mainScreen.bounds.size;
    
    UIImage* firstForklift = [forkliftAnimation objectAtIndex:0];
    
    forkliftForkLength = 0.696969697;
    pickupPadding = 0.06060606061;///firstForklift.scale;
    pickupScaleExtra = 0.06060606061*firstForklift.scale;
    
    sock = s;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    forkliftAnimationFrames = forkliftAnimation;
    emissionAnimationFrames = emissionAnimation;
    wheelAnimationFrames = wheelAnimation;
    
    currentForkliftFrame = 0;
    currentEmissionFrame = 0;
    currentWheelFrame = 0;
    
    CGFloat sockHeight = [sock getCoreTheoreticalRect].size.height;
    CGFloat aspectRatio = sockHeight / firstForklift.size.height;
    CGFloat finalWidth = firstForklift.size.width*aspectRatio;
    
    height = sockHeight;
    width = finalWidth;
    
    forkliftFacesRight = [sock getCoreRect].origin.x+([sock getCoreRect].size.width/2) < screenSize.width/2;
    
    firstForklift = forkliftFacesRight ? [UIImage imageWithCGImage:firstForklift.CGImage scale:firstForklift.scale orientation:UIImageOrientationUpMirrored] : firstForklift;
    
    CGFloat x = forkliftFacesRight ? -width : screenSize.width;
    
    CGRect frame = CGRectMake(x, [sock getCoreRect].origin.y, width, height);
    self = [super initWithFrame:frame];
    [self setImage:firstForklift];
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.magnificationFilter = kCAFilterNearest;
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor blueColor].CGColor;
    
//    UIImage* firstEmission = [emissionAnimation objectAtIndex:0];
//    CGFloat emissionHeight = self.frame.size.height*0.5;
//    CGFloat emissionAspectRatio = emissionHeight / firstEmission.size.height;
//    CGFloat finalEmissionWidth = firstEmission.size.width*emissionAspectRatio;
//    firstEmission = forkliftFacesRight ? [UIImage imageWithCGImage:firstEmission.CGImage scale:firstEmission.scale orientation:UIImageOrientationUpMirrored] : firstEmission;
//    emissionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(forkliftFacesRight ? -finalEmissionWidth : self.frame.size.width, 0, finalEmissionWidth, emissionHeight)];
//    emissionImageView.contentMode = UIViewContentModeScaleAspectFit;
//    emissionImageView.layer.magnificationFilter = kCAFilterNearest;
//    [emissionImageView setImage:firstEmission];
//    [self addSubview:emissionImageView];
    
    UIImage* firstWheel = [wheelAnimation objectAtIndex:0];
    CGFloat wheelX = 0.7575757576;
    CGFloat wheelLeft = 0.0303030303;
    CGFloat wheelHeight = 0.1304347826*self.frame.size.height;
    CGFloat wheelAspectRatio = wheelHeight / firstWheel.size.height;
    CGFloat finalWheelWidth = firstWheel.size.width*wheelAspectRatio;
    
    wheelTop = [[UIImageView alloc] initWithFrame:CGRectMake(forkliftFacesRight ? self.frame.size.width*(wheelLeft) : self.frame.size.width*(wheelX), 0, finalWheelWidth, wheelHeight)];
    wheelTop.contentMode = UIViewContentModeScaleAspectFit;
    wheelTop.layer.magnificationFilter = kCAFilterNearest;
    //    emissionImageView.layer.borderWidth = 0.5;
    //    emissionImageView.layer.borderColor = [UIColor greenColor].CGColor;
    [wheelTop setImage:firstWheel];
    [self addSubview:wheelTop];
    
    wheelBottom = [[UIImageView alloc] initWithFrame:CGRectMake(forkliftFacesRight ? self.frame.size.width*(wheelLeft) : self.frame.size.width*(wheelX), self.frame.size.height-wheelHeight, finalWheelWidth, wheelHeight)];
    wheelBottom.contentMode = UIViewContentModeScaleAspectFit;
    wheelBottom.layer.magnificationFilter = kCAFilterNearest;
    //    emissionImageView.layer.borderWidth = 0.5;
    //    emissionImageView.layer.borderColor = [UIColor greenColor].CGColor;
    [wheelBottom setImage:firstWheel];
    [self addSubview:wheelBottom];
    
    return self;
}

-(void) animateAnimation {
    NSInteger nextForkliftFrame = (currentForkliftFrame+1)%forkliftAnimationFrames.count;
    currentForkliftFrame = nextForkliftFrame;
    UIImage* next = [forkliftAnimationFrames objectAtIndex:nextForkliftFrame];
    next = forkliftFacesRight ? [UIImage imageWithCGImage:next.CGImage scale:next.scale orientation:UIImageOrientationUpMirrored] : next;
    [self setImage: next];
    
    NSInteger nextEmissionFrame = (currentEmissionFrame+1)%emissionAnimationFrames.count;
    currentEmissionFrame = nextEmissionFrame;
    UIImage* nextEmission = [emissionAnimationFrames objectAtIndex:nextEmissionFrame];
    nextEmission = forkliftFacesRight ? [UIImage imageWithCGImage:nextEmission.CGImage scale:nextEmission.scale orientation:UIImageOrientationUpMirrored] : nextEmission;
    [emissionImageView setImage: nextEmission];
}

-(void) animateWheels {
    NSInteger nextWheelFrame = (currentWheelFrame+1)%wheelAnimationFrames.count;
    currentWheelFrame = nextWheelFrame;
    UIImage* next = [wheelAnimationFrames objectAtIndex:nextWheelFrame];
    [wheelTop setImage: next];
    [wheelBottom setImage:next];
}

-(void) animateWithSpeed:(NSTimeInterval)animateSpeed withCompletion: (void (^)(void)) completion {
    currentlyAnimating = true;
    
    [UIView animateWithDuration:animateSpeed animations:^{
        self.frame = CGRectMake(forkliftFacesRight == true ? [sock getCoreRect].origin.x-((1-forkliftForkLength+pickupPadding)*self.frame.size.width) : [sock getCoreRect].origin.x+((forkliftForkLength+pickupPadding)*self.frame.size.width)-(self.frame.size.width*forkliftForkLength), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        [sock removeFromSuperview];
//        sock.frame = CGRectMake(forkliftFacesRight == true ? self.frame.size.width*(1-forkliftForkLength+pickupPadding) : (-pickupPadding*self.frame.size.width), 0, sock.frame.size.width, sock.frame.size.height);
        [sock setRectFromCoreRect: CGRectMake(forkliftFacesRight == true ? self.frame.size.width*(1-forkliftForkLength+pickupPadding) : (-pickupPadding*self.frame.size.width), 0, sock.frame.size.width, sock.frame.size.height)];
        sock.layer.anchorPoint = CGPointMake(0.5, 0.5);
        [self addSubview:sock];
        
        //increase sock package size
        [UIView animateWithDuration:animateSpeed/2 animations:^void{
            CGAffineTransform t = CGAffineTransformMakeScale(1+pickupScaleExtra, 1+pickupScaleExtra);
            sock.transform = t;
        } completion:^(BOOL completed){
            CGRect transformedBounds = CGRectApplyAffineTransform(sock.bounds, sock.transform);
            [UIView animateWithDuration:animateSpeed animations:^{
                CGRect newRect = CGRectMake(forkliftFacesRight == true ? -(self.frame.size.width+(transformedBounds.size.width-sock.bounds.size.width)) : screenSize.width+(transformedBounds.size.width-sock.bounds.size.width), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                self.frame = newRect;
            } completion:^(BOOL finished){
                currentlyAnimating = false;
                completion();
            }];
        }];
    }];
}

@end
