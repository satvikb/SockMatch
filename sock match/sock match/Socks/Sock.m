//
//  Sock.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Sock.h"

@implementation Sock {
    CGRect boxFrame;
}

@synthesize inAPair;
@synthesize mainSockInPair;
@synthesize otherSockInPair;

@synthesize sockId;
@synthesize sockSize;
@synthesize onConvayorBelt;

@synthesize startTouchRect;
@synthesize theoreticalFrame;

@synthesize coreImageView;
@synthesize overlayImageView;
@synthesize veryTopImageView;
@synthesize veryTopImageView2;

@synthesize allowMovement;
@synthesize validSock;

@synthesize touchBeganBlock;
@synthesize touchMovedBlock;
@synthesize touchEndedBlock;
@synthesize animatingSize;

-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage*) image onBelt:(bool)startOnBelt extraPropTouchSpace:(CGFloat)extraSpace{
    
    sockId = sId;
    sockSize = size;
    onConvayorBelt = startOnBelt;
    inAPair = false;
    allowMovement = true;
    validSock = true;
    animatingSize = false;
    
    CGFloat heightAspectMutliplier = image.size.height/image.size.width;
    boxFrame = CGRectMake(pos.x, pos.y, width, width*heightAspectMutliplier);
    
    CGFloat multiplier = 1+extraSpace;
    CGFloat largeWidth = boxFrame.size.width*multiplier;
    CGFloat largeHeight = boxFrame.size.height*multiplier;
    CGFloat largeX = boxFrame.origin.x-(largeWidth-boxFrame.size.width)/2;
    CGFloat largeY = boxFrame.origin.y-(largeHeight-boxFrame.size.height)/2;
    
    self = [super initWithFrame:CGRectMake(largeX, largeY, largeWidth, largeHeight)];
//    self.layer.borderColor = [UIColor blackColor].CGColor;
//    self.layer.borderWidth = 2;
    
    // make the box frame center for children
    boxFrame.origin = CGPointMake((largeWidth/2)-boxFrame.size.width/2, (largeHeight/2)-boxFrame.size.height/2);
    theoreticalFrame = boxFrame;
    
    coreImageView = [[UIImageView alloc] initWithFrame:boxFrame];
    [coreImageView setImage:image];
    coreImageView.contentMode = UIViewContentModeScaleAspectFit;
    coreImageView.layer.magnificationFilter = kCAFilterNearest;
    coreImageView.userInteractionEnabled = true;
    coreImageView.layer.zPosition = 1;
    [self addSubview:coreImageView];
    
    overlayImageView = [[UIImageView alloc] initWithFrame:boxFrame];
    overlayImageView.contentMode = UIViewContentModeScaleAspectFit;
    overlayImageView.layer.magnificationFilter = kCAFilterNearest;
    overlayImageView.userInteractionEnabled = true;
    overlayImageView.layer.zPosition = 2;
    [self addSubview:overlayImageView];
    
    veryTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(boxFrame.origin.x+boxFrame.size.width/4, boxFrame.origin.y+boxFrame.size.height/4/*8*/, boxFrame.size.width/2, boxFrame.size.height/2)];
    veryTopImageView.contentMode = UIViewContentModeScaleAspectFit;
    veryTopImageView.layer.magnificationFilter = kCAFilterNearest;
//    veryTopImageView.layer.borderColor = [UIColor yellowColor].CGColor;
//    veryTopImageView.layer.borderWidth = 2;
    veryTopImageView.userInteractionEnabled = true;
    veryTopImageView.layer.zPosition = 3;
    [self addSubview:veryTopImageView];
    
    veryTopImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(boxFrame.origin.x+((boxFrame.size.width/8)*2.9), boxFrame.origin.y+((boxFrame.size.height/8)*5), boxFrame.size.height/3.9, boxFrame.size.height/3.9)];
    veryTopImageView2.contentMode = UIViewContentModeScaleAspectFit;
    veryTopImageView2.layer.magnificationFilter = kCAFilterNearest;
//        veryTopImageView2.layer.borderColor = [UIColor yellowColor].CGColor;
//        veryTopImageView2.layer.borderWidth = 1;
    veryTopImageView2.userInteractionEnabled = true;
    veryTopImageView2.layer.zPosition = 4;
//    [self addSubview:veryTopImageView2];
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if((!inAPair || mainSockInPair) && allowMovement){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        touchPoint = location;
        startTouchRect = [self getCoreRect];
        if(touchBeganBlock != nil){
            [self animateIncreaseCoreScale];
            touchBeganBlock(self, location);
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch*> *)touches withEvent:(UIEvent *)event {
    
    if((!inAPair || mainSockInPair) && allowMovement){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        
        if(touchMovedBlock != nil){
            touchMovedBlock(self, location, touchPoint);
        }
        
        touchPoint = location;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchEnd:[[touches anyObject] locationInView: nil]];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchEnd:[[touches anyObject] locationInView: nil]];
}

-(void)touchEnd:(CGPoint)location {
    if((!inAPair || mainSockInPair) && allowMovement){
        touchPoint = location;
        
        if(touchEndedBlock != nil){
            [self animateDecreaseCoreScale];
            touchEndedBlock(self, location);
        }
    }
}

-(void)animateIncreaseCoreScale {
//    self.animatingSize = true;
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
//        self.coreImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
//    } completion:^(BOOL completed){
//        self.animatingSize = false;
//    }];
}

-(void)animateDecreaseCoreScale {
//    self.animatingSize = true;
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^void{
//        self.coreImageView.transform = CGAffineTransformIdentity;//CGAffineTransformMakeScale(1.2, 1.2);
//    } completion:^(BOOL completed){
//        self.animatingSize = false;
//    }];
}

-(CGRect)getCoreRect{
    return CGRectMake(self.frame.origin.x+(self.frame.size.width/2-boxFrame.size.width/2), self.frame.origin.y+(self.frame.size.height/2-boxFrame.size.height/2), boxFrame.size.width, boxFrame.size.height);
}

//TODO also set the size?
-(void)setRectFromCoreRect:(CGRect)rect{
    //inverse all the things from getCoreTheoreticalRect
    CGFloat x = rect.origin.x-(self.frame.size.width/2-boxFrame.size.width/2);
    CGFloat y = rect.origin.y-(self.frame.size.height/2-boxFrame.size.height/2);
    CGRect f = self.frame;
    f.origin = CGPointMake(x, y);
    self.frame = f;
}

-(CGRect)getCoreTheoreticalRect{
    return CGRectMake(theoreticalFrame.origin.x+(theoreticalFrame.size.width/2-boxFrame.size.width/2), theoreticalFrame.origin.y+(theoreticalFrame.size.height/2-boxFrame.size.height/2), boxFrame.size.width, boxFrame.size.height);
}

-(void)setTheoreticalRectFromCoreTheoreticalRect:(CGRect)rect{
    //inverse all the things from getCoreTheoreticalRect
    CGFloat x = rect.origin.x-(theoreticalFrame.size.width/2-boxFrame.size.width/2);
    CGFloat y = rect.origin.y-(theoreticalFrame.size.height/2-boxFrame.size.height/2);
    theoreticalFrame.origin = CGPointMake(x, y);
}
@end
