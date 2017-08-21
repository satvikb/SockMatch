//
//  FocusOnRect.m
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "FocusOnRect.h"
#import "Functions.h"

@implementation FocusOnRect{
    UIView* top;
    UIView* left;
    UIView* right;
    UIView* bottom;
    
    bool visible;
    
    NSArray<UILabel*>* subLabels;
    UILabel* currentLabel;
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
    
//    for(UILabel* l in labels){
//        [self addSubview:l];
//    }
    
    UILabel* tapToContinue = [[UILabel alloc] initWithFrame:CGRectMake(0.25*screen.width, 0.5*screen.height, 0.5*screen.width, 0.1*screen.height)];
    tapToContinue.text = @"tap to continue.";
    tapToContinue.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    tapToContinue.textAlignment = NSTextAlignmentCenter;
    tapToContinue.textColor = [UIColor whiteColor];
    [self addSubview:tapToContinue];
    
    if(labels.count > 0){
        [self addSubview:[labels objectAtIndex:0]];
        currentLabel = [labels objectAtIndex:0];
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

-(bool)showNextLabel {
    NSInteger nextIndex = [subLabels indexOfObject:currentLabel]+1;
    
    if(nextIndex <= subLabels.count-1){
        [currentLabel removeFromSuperview];
        currentLabel = [subLabels objectAtIndex:nextIndex];
        [self addSubview:currentLabel];
        return true;
    }
    
    return false;
}

@end
