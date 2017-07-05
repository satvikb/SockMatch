//
//  Button.m
//  sock match
//
//  Created by Satvik Borra on 7/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Button.h"

@implementation Button
@synthesize pressedDownImage;
@synthesize normalImage;
@synthesize block;
@synthesize pressedDown;

-(id)initBoxButtonWithFrame:(CGRect)frame withNormalImage:(UIImage *)normalImg pressedDownImage:(UIImage*)pressedDownImg withBlock:(ButtonPressDown)btnPressDown{
    pressedDownImage = pressedDownImg;
    normalImage = normalImg;
    block = btnPressDown;
    
//    self = [super initWithImage:image highlightedImage:highlightedImage];
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = true;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self setImage:normalImage];
    return self;
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), point)){
        [self setPushedDown];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), point)){
        if(!pressedDown){
            [self setPushedDown];
        }
    }else{
        [self setPushedUp];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), point)){
        if(block != nil){
            block();
        }
    }
    [self setPushedUp];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if(CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), point)){
        
    }
    [self setPushedUp];
}

-(void) setPushedDown {
    self.pressedDown = true;
    [self setImage:pressedDownImage];
}

-(void) setPushedUp {
    self.pressedDown = false;
    [self setImage:normalImage];
}

@end
