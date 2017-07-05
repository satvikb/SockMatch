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
}

-(id)initWithFrame:(CGRect)frame frameImage:(UIImage*)frameImage innerImage:(UIImage*)innerImage {
    self = [super initWithFrame:frame];
//    self.layer.borderWidth = 2;
//    self.layer.borderColor = [UIColor blueColor].CGColor;
    
    CGFloat aspect = frame.size.width / frameImage.size.width;
    
    frameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frameImage.size.height*aspect)];
    frameImageView.layer.magnificationFilter = kCAFilterNearest;
    frameImageView.contentMode = UIViewContentModeScaleAspectFit;
    [frameImageView setImage:frameImage];
    
    CGFloat leftPadding = 0.025;
    CGFloat bottomPadding = 0.08333333333;
    CGFloat x = frameImageView.frame.size.width*leftPadding;
    CGFloat y = frameImageView.frame.size.height*bottomPadding;
    
    
    innerBarStartWidth = frameImageView.frame.size.width-(x*2);
    innerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, innerBarStartWidth, frameImageView.frame.size.height-(y*2))];
    innerImageView.layer.magnificationFilter = kCAFilterNearest;
    innerImageView.contentMode = UIViewContentModeScaleToFill;
//    innerImageView.layer.borderWidth = 2;
    [innerImageView setImage:innerImage];
    
    [self addSubview:innerImageView];
    [self addSubview:frameImageView];
    
    return self;
}

-(void)setInnerBarPercentage:(CGFloat)percent{
    CGRect f = innerImageView.frame;
    f.size = CGSizeMake(innerBarStartWidth*percent, f.size.height);
    
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
