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

-(id)initWithFrame:(CGRect)frame repeatTime:(int)repeatTimes text:(NSString*)text{
    self = [super initWithFrame:frame];
    
    if(repeatTimes == 0){
        continuousAnimating = true;
    }
    
    repeatTimesLeft = repeatTimes;
    self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    [self addSubview:label];
    
    self.layer.opacity = 0;
    [self animate];
    
    return self;
}

-(void)animate {
    
    if(repeatTimesLeft > 0 || continuousAnimating){
        [UIView animateWithDuration:1 animations:^void{
            self.layer.opacity = 0.5;// = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        } completion:^(BOOL finished){
            [UIView animateWithDuration:1 animations:^void{
                self.layer.opacity = 0;// = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            } completion:^(BOOL finished){
                repeatTimesLeft -= 1;
                [self animate];
            }];
        }];
    }
}

-(void)stopAnimating{
    continuousAnimating = false;
    repeatTimesLeft = 0;
}

@end
