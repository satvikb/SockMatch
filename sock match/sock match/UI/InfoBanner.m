//
//  InfoBanner.m
//  sock match
//
//  Created by Satvik Borra on 7/8/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "InfoBanner.h"

@implementation InfoBanner{
    int repeatTimesLeft;
    bool shouldStopAnimating;
    bool continuousAnimating;
}

@synthesize block;
-(id)initWithFrame:(CGRect)frame repeatTime:(int)repeatTimes text:(NSString*)text{
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = false;
    if(repeatTimes == 0){
        continuousAnimating = true;
    }
    
    repeatTimesLeft = repeatTimes;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    [self addSubview:label];
    
    self.layer.opacity = 0;
    [self animate];
    
    return self;
}

-(void)animate {
    
    if(repeatTimesLeft > 0 || continuousAnimating){
        [UIView animateWithDuration:0.4 animations:^void{
            self.layer.opacity = 0.5;// = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.4 animations:^void{
                self.layer.opacity = 0;// = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            } completion:^(BOOL finished){
                repeatTimesLeft -= 1;
                [self animate];
            }];
        }];
    }else{
        if(block != nil){
            block();
        }
    }
}

-(void)stopAnimating{
    continuousAnimating = false;
    repeatTimesLeft = 0;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return NO;
}

@end
