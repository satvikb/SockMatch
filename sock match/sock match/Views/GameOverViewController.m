//
//  GameOverViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameOverViewController.h"

@interface GameOverViewController (){
    UIImageView* gameOverText;
    UIImageView* againButton;
}

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    gameOverText = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.175, 0.5, 0.2)]];
    //    testLabel.layer.borderWidth = 1;
    //    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [gameOverText setImage:[UIImage imageNamed:@"gameOver"]];
    gameOverText.layer.magnificationFilter = kCAFilterNearest;
    gameOverText.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:gameOverText];
    
//    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [menuButton addTarget:self action:@selector(pressMenuButton:) forControlEvents:UIControlEventTouchUpInside];
//    [menuButton setTitle:@"menu" forState:UIControlStateNormal];
//    [menuButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    menuButton.layer.borderWidth = 2;
//    menuButton.layer.zPosition = 5;
//    menuButton.layer.borderColor = [UIColor blueColor].CGColor;
//    menuButton.frame = [self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.1)];
//    [self.view addSubview:menuButton];
    
    againButton = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.195)]];
    UIImage* againImage = [UIImage imageNamed:@"again"];
    againImage = [againImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    againImage = [self image:againImage WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    //    playButton.tintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    [againButton setImage:againImage];
    againButton.layer.magnificationFilter = kCAFilterNearest;
    againButton.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressMenuButton:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setDelegate:self];
    //Don't forget to set the userInteractionEnabled to YES, by default It's NO.
    againButton.userInteractionEnabled = YES;
    [againButton addGestureRecognizer:tapRecognizer];
    
    [self.view addSubview:againButton];
}

- (UIImage *)image:(UIImage*)image WithTint:(UIColor *)tintColor {
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

-(void)setScore:(int)score{
//    testLabel.text = [NSString stringWithFormat:@"game over %i", score];
    NSLog(@"reporting score");
    if([self.delegate respondsToSelector:@selector(reportGCScore:)]){
        [self.delegate reportGCScore:score];
    }
}

-(void)pressMenuButton:(id)sender{
//    NSLog(@"play button press");
    
    if([self.delegate respondsToSelector:@selector(switchFromGameOverToMenu:)]){
        [self.delegate switchFromGameOverToMenu:self];
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
