//
//  FocusOnRect.m
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "FocusOnRect.h"

@implementation FocusOnRect{
    UIView* top;
    UIView* left;
    UIView* right;
    UIView* bottom;
}

-(id)initWithRectToFocusOn:(CGRect)rect screenSize:(CGSize)screen{
    self = [super initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
    
    //create top
    top = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screen.width, rect.origin.y)];
    top.backgroundColor = [UIColor greenColor];
    top.layer.opacity = 0;
    [self addSubview:top];
    
    left = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y, rect.origin.x, rect.size.height)];
    left.backgroundColor = [UIColor blueColor];
    left.layer.opacity = 0;
    [self addSubview:left];
    
    right = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x+rect.size.width, rect.origin.y, screen.width-(rect.origin.x+rect.size.width), rect.size.height)];
    right.backgroundColor = [UIColor yellowColor];
    right.layer.opacity = 0;
    [self addSubview:right];
    
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y+rect.size.height, screen.width, screen.height-(rect.origin.y+rect.size.height))];
    bottom.backgroundColor = [UIColor redColor];
    bottom.layer.opacity = 0;
    [self addSubview:bottom];
    return self;
}

-(void)animateToOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion{
    [UIView animateWithDuration:duration animations:^void{
        top.layer.opacity = left.layer.opacity = right.layer.opacity = bottom.layer.opacity = opacity;
    } completion:^(BOOL finished){
        completion(finished);
    }];
}

@end
