//
//  EfficiencyBar.m
//  sock match
//
//  Created by Satvik Borra on 7/5/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "EfficiencyBar.h"

@implementation EfficiencyBar {
    UIImageView* frameImageView;
    UIImageView* innerImageView;
    CGFloat innerBarStartWidth;
    
    UILabel* percentLabel;
}

-(id)initWithFrame:(CGRect)frame frameImage:(UIImage*)frameImage innerImage:(UIImage*)innerImage {
    self = [super initWithFrame:frame];
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor blueColor].CGColor;
    
    CGFloat aspect = frame.size.width / frameImage.size.width;
    
    frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];//frameImage.size.height*aspect)];
    frameImageView.layer.magnificationFilter = kCAFilterNearest;
    frameImageView.contentMode = UIViewContentModeScaleToFill;
    frameImageView.layer.zPosition = 3;
    [frameImageView setImage:frameImage];
    
    CGFloat leftPadding = 0.05;
    CGFloat bottomPadding = 0.166666666;
    CGFloat x = frameImageView.frame.size.width*leftPadding;
    CGFloat y = frameImageView.frame.size.height*bottomPadding;
    
    
    innerBarStartWidth = frameImageView.frame.size.width-(x*2);
    innerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, innerBarStartWidth, frameImageView.frame.size.height-(y*2))];
    innerImageView.layer.magnificationFilter = kCAFilterNearest;
    innerImageView.contentMode = UIViewContentModeScaleToFill;
//    innerImageView.layer.borderWidth = 2;
    innerImageView.layer.zPosition = 5;
    [innerImageView setImage:innerImage];
    
    percentLabel = [[UILabel alloc] initWithFrame:CGRectMake(innerImageView.frame.size.width*0.05, 0, innerImageView.frame.size.width, innerImageView.frame.size.height)];
    percentLabel.textAlignment = NSTextAlignmentLeft;
    percentLabel.text = @"100%";
    percentLabel.textColor = [UIColor whiteColor];
    [innerImageView addSubview:percentLabel];
    
    [self addSubview:innerImageView];
    [self addSubview:frameImageView];
    
    return self;
}

-(void)setInnerBarPercentage:(CGFloat)percent{
    CGRect f = innerImageView.frame;
    f.size = CGSizeMake(innerBarStartWidth*percent, f.size.height);
    
    percentLabel.text = [NSString stringWithFormat:@"%i%%", (int)(percent*100)];
    
    [UIView animateWithDuration:0.5 animations:^void{
        innerImageView.frame = f;
    }];
//    innerImageView.frame = CGRectInset(innerImageView.frame, -(innerBarStartWidth-(innerBarStartWidth*percent)), 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
