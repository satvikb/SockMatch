//
//  SettingsViewController.m
//  sock match
//
//  Created by Satvik Borra on 8/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "SettingsViewController.h"
#import "Sock.h"
#import "Flurry.h"

#import "GameAlertView.h"
#import "CreditsView.h"

@interface SettingsViewController () {

}

@end


@implementation SettingsViewController

@synthesize settingsTitle;
@synthesize titleFrame;
@synthesize backButton;
@synthesize creditsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;

    settingsTitle = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.15, 0.2, 0.7, 0.195)]];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [settingsTitle setImage:[UIImage imageNamed:@"settings"]];
    settingsTitle.layer.magnificationFilter = kCAFilterNearest;
    settingsTitle.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:settingsTitle];
    
    titleFrame = settingsTitle.frame;

    backButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.7, 0.05, 0.25, 0.1)] withText:@"back" withBlock:^void{
        [self pressBackButton:backButton];
    }];
    backButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:25];
    //    playButton.layer.borderWidth = 3;
    backButton.layer.zPosition = 103;
    [self.view addSubview:backButton];

    CGFloat propHeight = ([self propX:0.9]*0.2)/self.view.frame.size.height;
    [self createSettingViewWithPropFrame:CGRectMake(0.05, 0.6, 0.9, propHeight) settingType:Sound];
//    [self createSettingViewWithPropFrame:CGRectMake(0.05, 0.6+propHeight, 0.9, propHeight) settingType:GameAlertSockType];
//    [self createSettingViewWithPropFrame:CGRectMake(0.05, 0.6+(propHeight*2), 0.9, propHeight) settingType:GameAlertSockSize];
    
    
    
    creditsButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.4, 0.925, 0.2, 0.05)] withText:@"credits" withBlock:^void{
        [Flurry logEvent:@"CreditsPressed"];
        [self pressCreditsButton:creditsButton];
    }];
    creditsButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:20];
    creditsButton.layer.zPosition = 113;
    [self.view addSubview:creditsButton];

}

-(void)createSettingViewWithPropFrame:(CGRect)propFrame settingType:(SettingTypes)type{
    SettingView* settingView = [[SettingView alloc] initWithFrame:[self propToRect:propFrame] settingType:type];
//    settingView.layer.borderWidth = 2;
    __unsafe_unretained typeof(SettingView*) ws = settingView;

    [settingView setTouchBeganBlock:^void{
        [[Settings sharedInstance] toggleSetting:type];
        
        if([self.delegate respondsToSelector:@selector(settingChanged:)]){
            [self.delegate settingChanged:type];
        }
        
        [ws updateSetting:type];
    }];
    [self.view addSubview:settingView];
    
    [settingView setFrame:CGRectIntegral(settingView.frame)];
    settingView.center = CGPointMake(round(settingView.center.x), round(settingView.center.y));
}

-(void)pressBackButton:(id)sender{
    //    id<MenuTransition> strongDelegate = self.delegate;
    
    if([self.delegate respondsToSelector:@selector(switchFromSettingsToMenu:)]){
        [self.delegate switchFromSettingsToMenu:self];
    }
}

-(void)pressCreditsButton:(id)sender{
    CreditsView* credits = [[CreditsView alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    credits.layer.zPosition = 250;
    [self.view addSubview:credits];
}

-(int) getRandomSockId {
    return [Functions randomNumberBetween:0 maxNumber:4];
}

-(SockSize) getRandomSockSize {
    return [Functions randomNumberBetween:0 maxNumber:2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

-(CGFloat) propY:(CGFloat) y {
    return y*self.view.frame.size.height;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = [[self view] frame];
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}
@end
