//
//  MenuViewController.m
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "MenuViewController.h"
#import "BoxButton.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.168627451 green:0.168627451 blue:0.168627451 alpha:1];
    self.view.userInteractionEnabled = true;
    
    UILabel* testLabel = [[UILabel alloc] initWithFrame: [self propToRect:CGRectMake(0.25, 0.125, 0.5, 0.2)]];
//    NSLog(@"%@", CGRectMake(0.25, 0.25, 0.5, 0.2));
    testLabel.text = @"transal";
    testLabel.layer.borderWidth = 2;
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    testLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:testLabel];
    
    CGSize foregroundOffset = [self propToRect:CGRectMake(0, 0, -0.01, -0.005)].size;
    BoxButton* btn = [[BoxButton alloc] initBoxButton: [self propToRect: CGRectMake(0.25, 0.5, 0.5, 0.125)] foregroundOffset: foregroundOffset forBlock: ^void{
        NSLog(@"From set block");
    }];
//    btn.layer.borderWidth = 2;
//    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    btn.layer.backgroundColor = [UIColor greenColor].CGColor;
    btn.userInteractionEnabled = true;
    
//    __weak typeof(BoxButton) *weakBtn = btn;
    [btn setBlock: ^void (){
        NSLog(@"Custom block");
//        [weakBtn pushUpFrame];
    }];
    
    [self.view addSubview:btn];
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
