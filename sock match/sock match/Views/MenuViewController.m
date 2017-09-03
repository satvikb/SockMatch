//
//  MenuViewController.m
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "MenuViewController.h"
#import "Sock.h"
#import "Flurry.h"

#import "GameAlertView.h"

@interface MenuViewController () {}

@end


@implementation MenuViewController

@synthesize gameTitle;
@synthesize titleFrame;
@synthesize playButton;
@synthesize gameCenterButton;
@synthesize settingsButton;
@synthesize highScoreLabel;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    gameTitle = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.15, 0.2, 0.7, 0.195)]];
//    gameTitle.layer.borderWidth = 1;
//    gameTitle.layer.borderColor = [UIColor whiteColor].CGColor;
    [gameTitle setImage:[UIImage imageNamed:@"gameTitle"]];
    gameTitle.layer.magnificationFilter = kCAFilterNearest;
    gameTitle.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:gameTitle];
    
    titleFrame = gameTitle.frame;
    
    UIImage* playImage = [UIImage imageNamed:@"UIFrame"];
    UIImage* playImageDown = [UIImage imageNamed:@"playPressed"];
    playImage = [self image:playImage WithTint:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
    playImageDown = [self image:playImageDown WithTint:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
    playButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.1)] withText:@"play" withBlock:^void{
        [self pressPlayButton:playButton];
    }];
//    playButton.layer.borderWidth = 3;
    playButton.layer.zPosition = 103;
    [self.view addSubview:playButton];
    
    CGFloat gcBtnWidth = [self propX: 0.15];
    CGFloat gcPadding = [self propX:0.01];
    CGRect metaFrame = [self propToRect:CGRectMake(0.85, 1, 0.15, 0)];
    gameCenterButton = [[UIImageView alloc] initWithFrame: CGRectMake(metaFrame.origin.x-gcPadding, metaFrame.origin.y-gcBtnWidth-gcPadding, metaFrame.size.width, gcBtnWidth)];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIImage* gcImage = [UIImage imageNamed:@"UIGC"];
//    gcImage = [gcImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    gcImage = [self image:playImage WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    //    playButton.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [gameCenterButton setImage:gcImage];
    gameCenterButton.layer.magnificationFilter = kCAFilterNearest;
    gameCenterButton.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *gcTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressGCButton:)];
    [gcTapRecognizer setNumberOfTouchesRequired:1];
    [gcTapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    gameCenterButton.userInteractionEnabled = YES;
    [gameCenterButton addGestureRecognizer:gcTapRecognizer];
    
    [self.view addSubview:gameCenterButton];
    
    
    
    
    
    
    
    
    CGFloat settingBtnWidth = [self propX: 0.15];
    CGFloat settingPadding = [self propX:0.01];
    CGRect settingMetaFrame = [self propToRect:CGRectMake(0, 1, 0.15, 0)];
    settingsButton = [[UIImageView alloc] initWithFrame: CGRectMake(settingMetaFrame.origin.x+settingPadding, settingMetaFrame.origin.y-settingBtnWidth-settingPadding, settingMetaFrame.size.width, settingBtnWidth)];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIImage* settingImage = [UIImage imageNamed:@"settingscog"];
    //    gcImage = [gcImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    //    gcImage = [self image:playImage WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    //    playButton.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [settingsButton setImage:settingImage];
    settingsButton.layer.magnificationFilter = kCAFilterNearest;
    settingsButton.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *settingTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressSettingButton:)];
    [settingTapRecognizer setNumberOfTouchesRequired:1];
    [settingTapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    settingsButton.userInteractionEnabled = YES;
    [settingsButton addGestureRecognizer:settingTapRecognizer];
    
    [self.view addSubview:settingsButton];
    
    
    
    
    
    highScoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0.3, 0.8, 0.4, 0.1)]];
    highScoreLabel.textAlignment = NSTextAlignmentCenter;
//    [UIFont fontWithName:@"Pixel_3" size:
    highScoreLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:40]];
    highScoreLabel.numberOfLines = 0;
//    highScoreLabel.lineBreakMode = NSLineBreak
    highScoreLabel.adjustsFontSizeToFitWidth = true;
//    highScoreLabel.layer.borderWidth = 2;
//    highScoreLabel.layer.zPosition = 103;
    [self.view addSubview:highScoreLabel];
}

- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor{
    UIGraphicsBeginImageContextWithOptions (image.size, NO, image.scale); // for correct resolution on retina, thanks @MobileVet
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // image drawing code here
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextDrawImage(context, rect, image.CGImage);
    
    // tint image (loosing alpha) - the luminosity of the original image is preserved
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
    CGContextDrawImage(context, rect, image.CGImage);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}

-(void)pressPlayButton:(id)sender{
//    id<MenuTransition> strongDelegate = self.delegate;
    
    if([self.delegate respondsToSelector:@selector(switchFromMenuToGame:)]){
        [self.delegate switchFromMenuToGame:self];
    }
}

-(void)pressGCButton:(id)sender{
    NSLog(@"GAME CENTER");
    [Flurry logEvent:@"GameCenterButtonPress"];
    
    if([self.delegate respondsToSelector:@selector(menuGameCenterButton)]){
        [self.delegate menuGameCenterButton];
    }
}

-(void)pressSettingButton:(id)sender{
    NSLog(@"GAME CENTER");
    [Flurry logEvent:@"GameCenterButtonPress"];
    
    if([self.delegate respondsToSelector:@selector(switchFromMenuToSettings:)]){
        [self.delegate switchFromMenuToSettings:self];
    }
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
