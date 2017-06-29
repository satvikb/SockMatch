//
//  SockTouch.m
//  sock match
//
//  Created by Satvik Borra on 6/28/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "SockTouch.h"
#import "Sock.h"

@implementation SockTouch

@synthesize touchBeganBlock;
@synthesize touchMovedBlock;
@synthesize touchEndedBlock;

-(id)initWithSock:(Sock*)s extraPropSpace:(CGFloat)extraSpace{
    CGFloat multiplier = 1+extraSpace;
    CGFloat width = s.frame.size.width*multiplier;
    CGFloat height = s.frame.size.height*multiplier;
    CGFloat x = -(width-s.frame.size.width)/2;
    CGFloat y = -(height-s.frame.size.height)/2;
    self = [super initWithFrame:CGRectMake(x, y, width, height)];
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 2;
    self.userInteractionEnabled = true;
    return self;
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"__TOUCH %@", NSStringFromCGPoint([[touches anyObject] locationInView:nil]));
    if(touchBeganBlock != nil){
        touchBeganBlock(touches, event);
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(touchMovedBlock != nil){
        touchMovedBlock(touches, event);
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(touchEndedBlock != nil){
        touchEndedBlock(touches, event);
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(touchEndedBlock != nil){
        touchEndedBlock(touches, event);
    }
}

@end
