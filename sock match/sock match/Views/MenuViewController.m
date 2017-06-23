//
//  MenuViewController.m
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "MenuViewController.h"
#import "Sock.h"

@interface MenuViewController ()

@end


@implementation MenuViewController
@synthesize gameTitle;
@synthesize titleFrame;
@synthesize playButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    
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
    playImage = [playImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    playImage = [self image:playImage WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
//    playButton.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
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
}

- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor
{
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
    id<MenuTransition> strongDelegate = self.delegate;
    
    if([strongDelegate respondsToSelector:@selector(switchFromMenuToGame:)]){
        [strongDelegate switchFromMenuToGame:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = [[self view] frame];
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
