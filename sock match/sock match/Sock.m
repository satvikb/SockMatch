//
//  Sock.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Sock.h"

@implementation Sock

@synthesize inAPair;
@synthesize mainSockInPair;
@synthesize otherSockInPair;

@synthesize sockId;
@synthesize sockSize;
@synthesize onConvayorBelt;

@synthesize theoreticalFrame;

@synthesize overlayImageView;
@synthesize veryTopImageView;

@synthesize allowMovement;
@synthesize validSock;

@synthesize touchBeganBlock;
@synthesize touchMovedBlock;
@synthesize touchEndedBlock;

-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage*) image onBelt:(bool)startOnBelt{
//    NSLog(@"Image %@", image);
    self = [super initWithImage:image];
    
    sockId = sId;
    sockSize = size;
    onConvayorBelt = startOnBelt;
    inAPair = false;
    allowMovement = true;
    validSock = true;
    
    CGFloat heightAspectMutliplier = image.size.height/image.size.width;
    CGRect boxFrame = CGRectMake(pos.x, pos.y, width, width*heightAspectMutliplier);
    self.frame = boxFrame;
    theoreticalFrame = boxFrame;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.userInteractionEnabled = true;
    
    overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, boxFrame.size.width, boxFrame.size.height)];
    overlayImageView.contentMode = UIViewContentModeScaleAspectFit;
    overlayImageView.layer.magnificationFilter = kCAFilterNearest;
    overlayImageView.userInteractionEnabled = true;
    overlayImageView.layer.zPosition = 1;
    [self addSubview:overlayImageView];
    
    veryTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(boxFrame.size.width/4, boxFrame.size.height/4, boxFrame.size.width/2, boxFrame.size.height/2)];
    veryTopImageView.contentMode = UIViewContentModeScaleAspectFit;
    veryTopImageView.layer.magnificationFilter = kCAFilterNearest;
//    veryTopImageView.layer.borderColor = [UIColor yellowColor].CGColor;
//    veryTopImageView.layer.borderWidth = 2;
    veryTopImageView.userInteractionEnabled = true;
    veryTopImageView.layer.zPosition = 2;
    [self addSubview:veryTopImageView];
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /*
     make self.size slightly bigger
     */
    
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
    /*
     put self.size back to normal
     */
    
//    if(!inAPair || mainSockInPair){
//        UITouch *touch = [touches anyObject];
//        CGPoint location = [touch locationInView:nil];
//        touchPoint = location;
//
//        if(touchEndedBlock != nil){
//            touchEndedBlock(self, location);
//        }
//    }
    [self touchEnd:[[touches anyObject] locationInView: nil]];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self touchEnd:[[touches anyObject] locationInView: nil]];
//    NSLog(@"TOUCH CANCELLED");
}

-(void)touchEnd:(CGPoint)location {
    if((!inAPair || mainSockInPair) && allowMovement){
        touchPoint = location;
        
        if(touchEndedBlock != nil){
            touchEndedBlock(self, location);
        }
    }
}

@end
