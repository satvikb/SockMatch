//
//  GameOverViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "GameOverViewController.h"
#import "Storage.h"

@interface GameOverViewController (){
    
    UILabel* scoreLabel;

    UILabel* highScoreLabel;
    UIImageView* gameOverText;
    
    Button* againButton;
    Button* menuButton;
    Button* shareButton;

    int score;
}

@end

@implementation GameOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    gameOverText = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.2, 0.5, 0.2)]];
//        gameOverText.layer.borderWidth = 1;
//        gameOverText.layer.borderColor = [UIColor whiteColor].CGColor;
    [gameOverText setImage:[UIImage imageNamed:@"gameOver"]];
    gameOverText.layer.magnificationFilter = kCAFilterNearest;
    gameOverText.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:gameOverText];
    
//    UIImage* againImage = [self image:[UIImage imageNamed:@"again"] WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
//    UIImage* againDownImage = [self image:[UIImage imageNamed:@"againPressed"] WithTint:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
    againButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.1)] withText:@"again" withBlock:^void{
        [self pressAgainButton];
    }];
    againButton.layer.zPosition = 151;
    againButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:50]];
    [self.view addSubview:againButton];
    
    menuButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.1, 0.8, 0.3, 0.1)] withText:@"home" withBlock:^void{
        [self pressMenuButton];
    }];
    menuButton.layer.zPosition = 151;
    menuButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
    [self.view addSubview:menuButton];
    
    shareButton = [[Button alloc] initBoxButtonWithFrame:[self propToRect:CGRectMake(0.6, 0.8, 0.3, 0.1)] withText:@"share" withBlock:^void{
        [self shareSheet];
    }];
    shareButton.layer.zPosition = 151;
    shareButton.textLabel.font = [UIFont fontWithName:@"Pixel_3" size:[Functions fontSize:25]];
    [self.view addSubview:shareButton];
    
    highScoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0.475, 1, 0.125)]];
    highScoreLabel.font = [UIFont fontWithName:@"Pixel_3" size:30];
    highScoreLabel.textAlignment = NSTextAlignmentCenter;
    highScoreLabel.text = @"";
    [self.view addSubview:highScoreLabel];

    scoreLabel = [[UILabel alloc] initWithFrame:[self propToRect:CGRectMake(0, 0, 1, 0.15)]];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.font = [UIFont fontWithName:@"Pixel_3" size:40];
    scoreLabel.adjustsFontSizeToFitWidth = true;
    scoreLabel.text = @"";
    scoreLabel.textColor = UIColor.whiteColor;
    [self.view addSubview:scoreLabel ];

}

-(void)shareSheet {
    NSString *textToShare = [NSString stringWithFormat:@"i just got %i in sock shop", score];
    NSURL *myWebsite = [NSURL URLWithString:@"http://apple.co/2stt9uK"];
    
    NSArray *objectsToShare = @[textToShare, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   @"com.apple.mobilenotes.SharingExtension",
                                   @"com.apple.reminders.RemindersEditorExtension",
                                   @"com.google.Drive.ShareExtension"
                                   ];
    
    activityVC.excludedActivityTypes = excludeActivities;
//    activityVC.activit
    [self presentViewController:activityVC animated:YES completion:nil];
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

-(void)setScore:(int)s{
//    testLabel.text = [NSString stringWithFormat:@"game over %i", score];
    NSLog(@"reporting score");
    
    scoreLabel.text = [NSString stringWithFormat:@"%i", s];
    self->score = s;
    
    if([Storage getSavedHighScore] < score){
        NSLog(@"New high score!");
        highScoreLabel.text = @"new high score!";
    }else{
        highScoreLabel.text = @"";
    }
    
    
    if([self.delegate respondsToSelector:@selector(gameEndScore:)]){
        [self.delegate gameEndScore:s];
    }
}

-(void)pressAgainButton{
    if([self.delegate respondsToSelector:@selector(switchFromGameOverToGame:)]){
        [self.delegate switchFromGameOverToGame:self];
    }
}

-(void)pressMenuButton{
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

//@implementation ActivityViewController
//
//- (BOOL)_shouldExcludeActivityType:(UIActivity *)activity
//{
//    if ([[activity activityType] isEqualToString:@"com.apple.reminders.RemindersEditorExtension"] ||
//        [[activity activityType] isEqualToString:@"com.apple.mobilenotes.SharingExtension"]) {
//        return YES;
//    }
//    return [super _shouldExcludeActivityType:activity];
//}
//@end

