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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    
    UILabel* testLabel = [[UILabel alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.125, 0.5, 0.2)]];
    //    NSLog(@"%@", CGRectMake(0.25, 0.25, 0.5, 0.2));
    testLabel.text = @"sock match";
    testLabel.layer.borderWidth = 5;
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    testLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:testLabel];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    playButton.layer.borderWidth = 2;
    playButton.layer.zPosition = 3000000;
    playButton.layer.borderColor = [UIColor blackColor].CGColor;
    playButton.frame = [self propToRect:CGRectMake(0.25, 0.6, 0.5, 0.1)];
    [self.view addSubview:playButton];
}

-(void)pressPlayButton:(UIButton*)sender{
    NSLog(@"play button press");
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
