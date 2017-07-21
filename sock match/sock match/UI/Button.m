//
//  Button.m
//  sock match
//
//  Created by Satvik Borra on 7/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Button.h"

@implementation Button{
    UIImageView* innerImageView;
    CGFloat innerBarStartWidth;
    
    UILabel* textLabel;
    bool labelDown;
}

@synthesize imageFrame;
@synthesize innerImageUp;
@synthesize innerImageDown;
@synthesize block;
@synthesize pressedDown;

const CGFloat innerBar3DOffset = 0.1111111111;

-(id)initBoxButtonWithFrame:(CGRect)frame withText:(NSString*)text withBlock:(ButtonPressDown)btnPressDown{
    imageFrame = [UIImage imageNamed:@"UIFrame"];//frameImg;
    innerImageUp = [UIImage imageNamed:@"UIInnerUp"];//innerImgUp;
    innerImageDown = [UIImage imageNamed:@"UIInnerDown"];//innerImgDown;
    block = btnPressDown;
    
    CGFloat aspect = frame.size.width / imageFrame.size.width;
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, imageFrame.size.height*aspect)];
    self.userInteractionEnabled = true;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.contentMode = UIViewContentModeScaleAspectFit;
    
//    [self setImage:imageFrame];
    
    CGFloat leftPadding = 0.025;
    CGFloat bottomPadding = 0.08333333333;
    CGFloat x = self.frame.size.width*leftPadding;
    CGFloat y = self.frame.size.height*bottomPadding;
    
    innerBarStartWidth = self.frame.size.width-(x*2);
    innerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, innerBarStartWidth, self.frame.size.height-(y*2))];
    innerImageView.layer.magnificationFilter = kCAFilterNearest;
    innerImageView.contentMode = UIViewContentModeScaleToFill;
//        innerImageView.layer.borderWidth = 2;
    [innerImageView setImage:innerImageUp];
    
    [self addSubview:innerImageView];
//    self = [super initWithImage:image highlightedImage:highlightedImage];
    
    CGFloat ox = innerImageView.frame.size.width*0.05;
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerImageView.frame.origin.x+ox, innerImageView.frame.origin.y, innerImageView.frame.size.width-(ox*2), innerImageView.frame.size.height-(innerImageView.frame.size.height*innerBar3DOffset))];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.adjustsFontSizeToFitWidth = true;
//    textLabel.layer.borderWidth = 2;
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:40]];
    [self addSubview:textLabel];
    
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
    [innerImageView setImage:innerImageDown];
    
    if(!labelDown){
        textLabel.frame = CGRectOffset(textLabel.frame, 0, (innerImageView.frame.size.height*innerBar3DOffset));
        labelDown = true;
    }
}

-(void) setPushedUp {
    self.pressedDown = false;
    [innerImageView setImage:innerImageUp];
    
    if(labelDown){
        textLabel.frame = CGRectOffset(textLabel.frame, 0, -(innerImageView.frame.size.height*innerBar3DOffset));
        labelDown = false;
    }
}

@end
