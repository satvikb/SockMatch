//
//  SettingView.m
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "SettingView.h"

@implementation SettingView

-(id)initWithFrame:(CGRect)frame settingType:(SettingTypes)type{
    self = [super initWithFrame:frame];
    
    CGFloat height = frame.size.width*0.2;
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.8, height)];
    textLabel.text = [[Settings sharedInstance] getSettingTextForType: type];
    textLabel.textColor = UIColor.blackColor;
    textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:20]];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:textLabel];
    
    
    UIView* boxView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.8, 0, height, height)];
    boxView.layer.borderWidth = 2;
    [self addSubview:boxView];
    
    return self;
}

@end
