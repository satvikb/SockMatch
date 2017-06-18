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
@synthesize onPairConvayorBelt;

@synthesize touchBeganBlock;
@synthesize touchMovedBlock;
@synthesize touchEndedBlock;

-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId imageName:(NSString*) imgName onBelt:(bool)startOnBelt{
    UIImage* image = [UIImage imageNamed:imgName];
//    NSLog(@"Image %@", image);
    self = [super initWithImage:image];
    
    sockId = sId;
    sockSize = size;
    imageName = imgName;
    onConvayorBelt = startOnBelt;
    onPairConvayorBelt = false;
    inAPair = false;
    
    CGFloat heightAspectMutliplier = image.size.height/image.size.width;
    CGRect boxFrame = CGRectMake(pos.x, pos.y, width, width*heightAspectMutliplier);
    self.frame = boxFrame;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.userInteractionEnabled = true;
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /*
     make self.size slightly bigger
     */
    
    if(!inAPair || mainSockInPair){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        touchPoint = location;
        
        if(touchBeganBlock != nil){
            touchBeganBlock(self, location);
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch*> *)touches withEvent:(UIEvent *)event {
    
    if(!inAPair || mainSockInPair){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        
        CGPoint delta = CGPointMake(location.x-touchPoint.x, location.y-touchPoint.y);
        self.frame = CGRectOffset( self.frame, delta.x, delta.y );
        touchPoint = location;
        
//        if(otherSockInPair != nil){
//            otherSockInPair.frame = CGRectOffset( self.frame, delta.x, delta.y );
//        }
        
        if(touchMovedBlock != nil){
            touchMovedBlock(self, location);
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    /*
     put self.size back to normal
     */
    
    if(!inAPair || mainSockInPair){
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:nil];
        touchPoint = location;
        
        if(touchEndedBlock != nil){
            touchEndedBlock(self, location);
        }
    }
}

@end
