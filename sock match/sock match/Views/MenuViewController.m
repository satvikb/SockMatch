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

@interface MenuViewController () {
    NSMutableArray<UIImage*>* sockPackages;
    NSMutableArray<UIImage*>* forkliftAnimation;
    NSMutableArray<UIImage*>* wheelAnimation;
    
    // random forklifts
    CGFloat randomForkliftTimer;
    CGFloat timeToCreateRandomForklift;
    
    CGFloat forkliftWheelTimer;
    CGFloat timeToAnimateWheels;
}

@end


@implementation MenuViewController

@synthesize forklifts;
@synthesize gameTitle;
@synthesize titleFrame;
@synthesize playButton;
@synthesize gameCenterButton;

-(id)initWithForkliftAnimation:(NSMutableArray<UIImage*>*)forklift andWheel:(NSMutableArray<UIImage*>*)wheels sockPackages:(NSMutableArray<UIImage*>*)packages{
    self = [super init];
    
    forklifts = [[NSMutableArray alloc] init];
    sockPackages = packages;
    forkliftAnimation = forklift;
    wheelAnimation = wheels;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    randomForkliftTimer = 0;
    timeToCreateRandomForklift = 3;
    
    forkliftWheelTimer = 0;
    timeToAnimateWheels = 0.2;
    
    gameTitle = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.2, 0.5, 0.195)]];
//    testLabel.layer.borderWidth = 1;
//    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [gameTitle setImage:[UIImage imageNamed:@"title"]];
    gameTitle.layer.magnificationFilter = kCAFilterNearest;
    gameTitle.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:gameTitle];
    
    titleFrame = gameTitle.frame;
    
    playButton = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.195)]];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIImage* playImage = [UIImage imageNamed:@"play"];
//    playImage = [playImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    playImage = [self image:playImage WithTint:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1]];
    [playButton setImage:playImage];
    playButton.layer.magnificationFilter = kCAFilterNearest;
    playButton.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressPlayButton:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    playButton.userInteractionEnabled = YES;
    [playButton addGestureRecognizer:tapRecognizer];
    
    [self.view addSubview:playButton];
    
    CGFloat gcBtnWidth = [self propX: 0.15];
    CGFloat gcPadding = [self propX:0.01];
    CGRect metaFrame = [self propToRect:CGRectMake(0.85, 1, 0.15, 0)];
    gameCenterButton = [[UIImageView alloc] initWithFrame: CGRectMake(metaFrame.origin.x-gcPadding, metaFrame.origin.y-gcBtnWidth-gcPadding, metaFrame.size.width, gcBtnWidth)];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIImage* gcImage = [UIImage imageNamed:@"gamecenter"];
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

-(void) gameFrame:(CADisplayLink*)tmr{
    if([self.delegate respondsToSelector:@selector(getAppState)]){
        if([self.delegate getAppState] == MainMenu){
            randomForkliftTimer += tmr.duration;
            forkliftWheelTimer += tmr.duration;
            
            if(randomForkliftTimer >= timeToCreateRandomForklift){
                [self createRandomForklift];
                randomForkliftTimer = 0;
            }
            
            if(forkliftWheelTimer >= timeToAnimateWheels){
                for(Forklift* f in forklifts){
                    switch (f.currentState) {
                        case None:
                            break;
                        case GoingToSock:
                            [f animateWheels];
                            break;
                        case PickingUpSock:
                            break;
                        case GoingBack:
                            [f animateWheelsBackward];
                        default:
                            break;
                    }
                }
                
                
                forkliftWheelTimer = 0;
            }
        }
    }
}

// TODO make them not overlap (seperate into rows or sth)
-(void)createRandomForklift{
    CGFloat y = [Functions randFromMin:0.5 toMax:0.9];
    
    int sockId = [self getRandomSockId];
    SockSize size = [self getRandomSockSize];
    
    CGRect newSockFrame = [self propToRect:CGRectMake(0, y, [Functions propSizeFromSockSize:size], 0)];
    //imageName:[NSString stringWithFormat:@"sock%i", sockId]
    
    bool fromLeft = [Functions randomNumberBetween:0 maxNumber:100] < 50;
    
    UIImage* img = [Functions randomNumberBetween:0 maxNumber:100] < 50 ? [sockPackages objectAtIndex:sockId] : nil;
    
    Forklift* fork = [[Forklift alloc] initDummyFromLeft:fromLeft sockImage:img sockSize:CGSizeMake(newSockFrame.size.width, newSockFrame.size.width) atY:newSockFrame.origin.y forkliftAnimationFrames:forkliftAnimation wheelAnimationFrames:wheelAnimation];
    
    fork.layer.zPosition = 102;
    [forklifts addObject:fork];
    [self.view addSubview:fork];
    
    CGFloat speed = [Functions randFromMin:1.5 toMax:4];
        
    [fork dummyAnimateWithSpeed:speed xTranslate:fromLeft == true ? [self propX:1]+fork.frame.size.width : -([self propX: 1]+fork.frame.size.width) withCompletion:^void{
        [fork removeFromSuperview];
        [forklifts removeObject:fork];
    }];
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
