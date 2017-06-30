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

@synthesize theoreticalFrame;

@synthesize coreImageView;
@synthesize overlayImageView;
@synthesize veryTopImageView;

@synthesize allowMovement;
@synthesize validSock;

@synthesize touchBeganBlock;
@synthesize touchMovedBlock;
@synthesize touchEndedBlock;

-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage*) image onBelt:(bool)startOnBelt extraPropTouchSpace:(CGFloat)extraSpace{
    
    sockId = sId;
    sockSize = size;
    onConvayorBelt = startOnBelt;
    inAPair = false;
    allowMovement = true;
    validSock = true;
    
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
    
    veryTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(boxFrame.origin.x+boxFrame.size.width/4, boxFrame.origin.y+boxFrame.size.height/4, boxFrame.size.width/2, boxFrame.size.height/2)];
    veryTopImageView.contentMode = UIViewContentModeScaleAspectFit;
    veryTopImageView.layer.magnificationFilter = kCAFilterNearest;
//    veryTopImageView.layer.borderColor = [UIColor yellowColor].CGColor;
//    veryTopImageView.layer.borderWidth = 2;
    veryTopImageView.userInteractionEnabled = true;
    veryTopImageView.layer.zPosition = 3;
    [self addSubview:veryTopImageView];
    
//    __unsafe_unretained typeof(self) weakSelf = self;
//    sockTouch = [[SockTouch alloc] initWithSock:self extraPropSpace:3];
//    [sockTouch setTouchBeganBlock:^void (NSSet<UITouch*>* touches, UIEvent* event){
//        NSLog(@"TOUCH BEGAN");
//        [weakSelf sockTouchesBegan:touches withEvent:event];
//    }];
//    [sockTouch setTouchMovedBlock:^void (NSSet<UITouch*>* touches, UIEvent* event){
//        [weakSelf sockTouchesMoved:touches withEvent:event];
//    }];
//    [sockTouch setTouchEndedBlock:^void (NSSet<UITouch*>* touches, UIEvent* event){
//        [weakSelf sockTouchesEnded:touches withEvent:event];
//    }];
//    sockTouch.layer.zPosition = 10;
//    [self addSubview:sockTouch];
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // TODO remove mainSockInPair
    if((!inAPair || mainSockInPair) && allowMovement){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        touchPoint = location;
        
        if(touchBeganBlock != nil){
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
            touchEndedBlock(self, location);
        }
    }
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
