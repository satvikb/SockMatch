//
//  SettingView.m
//  sock match
//
//  Created by Satvik Borra on 8/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "SettingView.h"

@implementation SettingView {
    UIView* toggleBoxView;
}

@synthesize touchBeganBlock;

-(id)initWithFrame:(CGRect)frame settingType:(SettingTypes)type{
    self = [super initWithFrame:frame];
    
    CGFloat height = frame.size.width*0.2;
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.75, height)];
    textLabel.text = [[Settings sharedInstance] getSettingTextForType: type];
    textLabel.textColor = UIColor.blackColor;
    textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:30]];
    textLabel.textAlignment = NSTextAlignmentLeft;
//    textLabel.adjustsFontSizeToFitWidth = true;
    [self addSubview:textLabel];
    
    
    UIView* boxView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width*0.8, 0, height, height)];
//    boxView.layer.borderWidth = 1;
    
    [self addSubview:boxView];
    toggleBoxView = [[UIView alloc] initWithFrame: CGRectIntegral(CGRectMake(boxView.frame.size.width*0.1, boxView.frame.size.height*0.1, boxView.frame.size.width*0.8, boxView.frame.size.height*0.8))];
    toggleBoxView.backgroundColor = [[Settings sharedInstance] getCurrentSetting:type] == true ? UIColor.blueColor : UIColor.clearColor;
    toggleBoxView.layer.borderWidth = 1;
    toggleBoxView.layer.cornerRadius = toggleBoxView.frame.size.width/2;
    [boxView addSubview:toggleBoxView];
    
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(touchBeganBlock != nil){
        touchBeganBlock();
    }
}

-(void)updateSetting:(SettingTypes)type{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    toggleBoxView.backgroundColor = [[Settings sharedInstance] getCurrentSetting:type] == true ? color : UIColor.clearColor;
}

@end
