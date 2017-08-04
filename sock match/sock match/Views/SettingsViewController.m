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

@interface SettingsViewController () {

}

@end


@implementation SettingsViewController

@synthesize settingsTitle;
@synthesize titleFrame;
@synthesize backButton;

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
    backButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:30];
    //    playButton.layer.borderWidth = 3;
    backButton.layer.zPosition = 103;
    [self.view addSubview:backButton];

    CGFloat propHeight = ([self propX:0.5]*0.2)/self.view.frame.size.height;
    [self createSettingViewWithPropFrame:CGRectMake(0.25, 0.6, 0.5, 0.2) settingType:Sound];
    [self createSettingViewWithPropFrame:CGRectMake(0.25, 0.6+propHeight, 0.5, 0.2) settingType:GameAlertSockType];
    [self createSettingViewWithPropFrame:CGRectMake(0.25, 0.6+(propHeight*2), 0.5, 0.2) settingType:GameAlertSockSize];

}

-(void)createSettingViewWithPropFrame:(CGRect)propFrame settingType:(SettingTypes)type{
    SettingView* settingView = [[SettingView alloc] initWithFrame:[self propToRect:propFrame] settingType:type];
    
    __unsafe_unretained typeof(SettingView*) ws = settingView;

    [settingView setTouchBeganBlock:^void{
        [[Settings sharedInstance] toggleSetting:type];
        
        if([self.delegate respondsToSelector:@selector(settingChanged:)]){
            [self.delegate settingChanged:type];
        }
        
        [ws updateSetting:type];
    }];
    [self.view addSubview:settingView];
}

-(void)pressBackButton:(id)sender{
    //    id<MenuTransition> strongDelegate = self.delegate;
    
    if([self.delegate respondsToSelector:@selector(switchFromSettingsToMenu:)]){
        [self.delegate switchFromSettingsToMenu:self];
    }
}

-(void) gameFrame:(CADisplayLink*)tmr{
//    if([self.delegate respondsToSelector:@selector(getAppState)]){
//        if([self.delegate getAppState] == MainMenu){
//            randomForkliftTimer += tmr.duration;
//            forkliftWheelTimer += tmr.duration;
//
//            if(randomForkliftTimer >= timeToCreateRandomForklift){
//                timeToCreateRandomForklift = [Functions randFromMin:1 toMax:4];
//                [self createRandomForklift];
//                randomForkliftTimer = 0;
//            }
//
//            if(forkliftWheelTimer >= timeToAnimateWheels){
//                for(Forklift* f in forklifts){
//                    switch (f.currentState) {
//                        case None:
//                            break;
//                        case GoingToSock:
//                            [f animateWheels];
//                            break;
//                        case PickingUpSock:
//                            break;
//                        case GoingBack:
//                            [f animateWheelsBackward];
//                        default:
//                            break;
//                    }
//                }
//
//                forkliftWheelTimer = 0;
//            }
//
//            [self handleForkliftAnimation:tmr.duration];
//        }
//    }
}

// so container can continue animations when play button is pressed
//-(void)handleForkliftAnimation:(CGFloat)delta {
//    forkliftAnimateTimer += delta;
//
//    if(forkliftAnimateTimer >= timeToAnimateForklift){
//        for(Forklift* f in forklifts){
//            [f animateAnimation];
//        }
//        forkliftAnimateTimer = 0;
//    }
//}
//
//// TODO make them not overlap (seperate into rows or sth)
//-(void)createRandomForklift{
//    CGFloat y = [Functions randFromMin:0.5 toMax:0.9];
//
//    int sockId = [self getRandomSockId];
//    SockSize size = [self getRandomSockSize];
//
//    CGRect newSockFrame = [self propToRect:CGRectMake(0, y, [Functions propSizeFromSockSize:size], 0)];
//    //imageName:[NSString stringWithFormat:@"sock%i", sockId]
//
//    bool fromLeft = [Functions randomNumberBetween:0 maxNumber:100] < 50;
//
//    UIImage* img = [Functions randomNumberBetween:0 maxNumber:100] < 50 ? [sockPackages objectAtIndex:sockId] : nil;
//
//    Forklift* fork = [[Forklift alloc] initDummyFromLeft:fromLeft boxImage:boxImage sockImage:img sockSize:CGSizeMake(newSockFrame.size.width, newSockFrame.size.width) atY:newSockFrame.origin.y forkliftAnimationFrames:forkliftAnimation wheelAnimationFrames:wheelAnimation];
//
//    fork.layer.zPosition = 102;
//    [forklifts addObject:fork];
//    [self.view addSubview:fork];
//
//    CGFloat speed = [Functions randFromMin:1.5 toMax:4];
//
//    [fork dummyAnimateWithSpeed:speed xTranslate:fromLeft == true ? [self propX:1]+fork.frame.size.width : -([self propX: 1]+fork.frame.size.width) withCompletion:^void{
//        [fork removeFromSuperview];
//        [forklifts removeObject:fork];
//    }];
//}

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
