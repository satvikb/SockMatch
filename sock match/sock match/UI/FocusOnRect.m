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
    
    bool visible;
    
    NSArray<UILabel*>* subLabels;
}

@synthesize touchBlock;

-(id)initWithRectToFocusOn:(CGRect)rect withLabels:(NSArray<UILabel*>*)labels screenSize:(CGSize)screen{
    self = [super initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
    
    //create top
    top = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screen.width, rect.origin.y)];
    top.backgroundColor = [UIColor blackColor];
    top.layer.opacity = 0;
    [self addSubview:top];
    
    left = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y, rect.origin.x, rect.size.height)];
    left.backgroundColor = [UIColor blackColor];
    left.layer.opacity = 0;
    [self addSubview:left];
    
    right = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x+rect.size.width, rect.origin.y, screen.width-(rect.origin.x+rect.size.width), rect.size.height)];
    right.backgroundColor = [UIColor blackColor];
    right.layer.opacity = 0;
    [self addSubview:right];
    
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y+rect.size.height, screen.width, screen.height-(rect.origin.y+rect.size.height))];
    bottom.backgroundColor = [UIColor blackColor];
    bottom.layer.opacity = 0;
    [self addSubview:bottom];
    
    for(UILabel* l in labels){
        [self addSubview:l];
    }
    
    subLabels = labels;
    
    return self;
}

-(void)hide:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion{
    [UIView animateWithDuration:duration animations:^void{
        top.layer.opacity = left.layer.opacity = right.layer.opacity = bottom.layer.opacity = opacity;
        for(UILabel* l in subLabels){
            l.layer.opacity = opacity;
        }
    } completion:^(BOOL finished){
        visible = false;
        completion(finished);
    }];
}

-(void)show:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion{
    [UIView animateWithDuration:duration animations:^void{
        top.layer.opacity = left.layer.opacity = right.layer.opacity = bottom.layer.opacity = opacity;
//        for(UILabel* l in subLabels){
//            l.layer.opacity = opacity;
//        }
    } completion:^(BOOL finished){
        visible = true;
        completion(finished);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"TOUCH");
    if(visible){
        touchBlock();
    }
}

@end
