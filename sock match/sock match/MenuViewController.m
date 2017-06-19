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
    
    
    UIImageView* testLabel = [[UIImageView alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.2, 0.5, 0.195)]];
//    testLabel.layer.borderWidth = 1;
//    testLabel.layer.borderColor = [UIColor blackColor].CGColor;
    [testLabel setImage:[UIImage imageNamed:@"title"]];
    testLabel.layer.magnificationFilter = kCAFilterNearest;
    testLabel.contentMode = UIViewContentModeScaleAspectFit;
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
