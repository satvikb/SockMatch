//
//  GameAlertView.m
//  sock match
//
//  Created by Satvik Borra on 7/21/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameAlertView.h"

@implementation GameAlertView{
    UIView* backgroundView;
    UIView* containerView;
    UILabel* titleText;
    UIImageView* imageView;
    UILabel* mainTextLabel;
    Button* acceptButton;
}

@synthesize buttonPressBlock;

-(id)initWithFrame:(CGRect)frame screenFrame:(CGRect)screen title:(NSString*)title text:(NSString*)text image:(UIImage*)img{
    self = [super initWithFrame:screen];
    
    backgroundView = [[UIView alloc] initWithFrame:screen];
    backgroundView.layer.backgroundColor = UIColor.blackColor.CGColor;
    backgroundView.layer.opacity = 0;
    
    [self addSubview:backgroundView];
    
    containerView = [[UIView alloc] initWithFrame:frame];
    containerView.backgroundColor = UIColor.whiteColor;
    containerView.layer.opacity = 0;
    [self addSubview:containerView];
    
    titleText = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.05, 0, 0.9, 0.2)]];
    titleText.text = title;
    titleText.textAlignment=  NSTextAlignmentCenter;
    titleText.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
    [containerView addSubview:titleText];

    if(img != nil){
        imageView = [[UIImageView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.2, 1, 0.3)]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.magnificationFilter = kCAFilterNearest;
//        imageView.layer.borderWidth = 2;
        [imageView setImage:img];
        [containerView addSubview:imageView];
        
        mainTextLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.05, 0.5, 0.9, 0.3)]];
    }else{
        mainTextLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.05, 0.2, 0.9, 0.6)]];
    }
    
    mainTextLabel.text = text;
    mainTextLabel.textAlignment = NSTextAlignmentCenter;
    mainTextLabel.numberOfLines = 0;
    mainTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    mainTextLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
//    mainTextLabel.layer.borderWidth = 2;
    [containerView addSubview:mainTextLabel];
    
    
    acceptButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.1, 0.8, 0.8, 0.2)] withText:@"continue" withBlock:^void{
        [self clickAccept];
    }];
    
//    [acceptButton setBackgroundColor:UIColor.grayColor];
//    acceptButton.layer.borderWidth = 2;
    [containerView addSubview:acceptButton];
    
    [self show];
    return self;
}

-(void)show{
    [UIView animateWithDuration:0.5 animations:^void{
        backgroundView.layer.opacity = 0.3;
        containerView.layer.opacity = 1;
    }];
}

-(void)hideAndRemove{
    [UIView animateWithDuration:0.5 animations:^void{
        backgroundView.layer.opacity = 0;
        containerView.layer.opacity = 0;
    } completion:^(BOOL completed){
        [self removeFromSuperview];
    }];
}

-(void)clickAccept{
    if(buttonPressBlock != nil){
        buttonPressBlock();
    }
}

-(CGFloat) propY:(CGFloat) y {
    return y*containerView.frame.size.height;
}

-(CGFloat) propX:(CGFloat) x {
    return x*containerView.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = containerView.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}
@end
