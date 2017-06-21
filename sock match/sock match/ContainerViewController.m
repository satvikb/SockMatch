//
//  ContainerViewController.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@end

@implementation ContainerViewController
@synthesize menuController;
@synthesize gameController;
@synthesize gameOverController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menuController = [[MenuViewController alloc] init];
    menuController.view.layer.zPosition = 100;
    menuController.delegate = self;
    
    gameController = [[GameViewController alloc] init];
    gameController.view.layer.zPosition = -100;
    gameController.delegate = self;
    
    gameOverController = [[GameOverViewController alloc] init];
    gameOverController.view.layer.zPosition = 150;
    gameOverController.delegate = self;
    
    [self displayContentController:gameController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
    [self displayContentController:gameOverController withFrame:[self propToRect:CGRectMake(1, 0, 1, 1)]];
    [self displayContentController:menuController withFrame:[self propToRect:CGRectMake(0, 0, 1, 1)]];
}

- (void) displayContentController: (UIViewController*) content withFrame:(CGRect) frame{
    [self addChildViewController:content];
    content.view.frame = frame;//[self frameForContentController];
    [self.view addSubview: content.view];
    
    [content didMoveToParentViewController:self];
}

-(void)switchFromMenuToGame:(MenuViewController*) menu{
    NSLog(@"sfasdfasdfsadfasdfasdfsd");
//    [self animateViewController:menu toNewPoint:[self propToRect:CGRectMake(-1, 0, 0, 0)].origin goingTo:gameController animationFinished:^void{
//        NSLog(@"STARTING GAME");
//        [gameController beginGame];
//    }];
    [self animateFromViewController:menu toPoint:[self propToRect:CGRectMake(-1, 0, 0, 0)].origin toViewController:gameController toPoint:CGPointZero animationFinished:^{
        NSLog(@"STARTING GAME %@", NSStringFromCGRect(gameController.view.frame));
        [gameController beginGame];
    }];
}

- (void) switchFromGameToGameOver:(GameViewController *)game withScore:(int)score {
    [gameOverController setScore:score];
//    [self animateViewController:gameOverController toNewPoint:[self propToRect:CGRectMake(0, 0, 0, 0)].origin goingTo: gameOverController animationFinished:^{
//        NSLog(@"Switced from game to game over");
//    }];
    [self animateFromViewController:game toPoint:CGPointZero toViewController:gameOverController toPoint:CGPointZero animationFinished:^{
        NSLog(@"Switced from game to game over %@ %@", NSStringFromCGRect(game.view.frame), gameOverController.view.backgroundColor);
    }];
}

- (void) switchFromGameOverToMenu:(GameOverViewController *)gameOver {
//    [self animateViewController:gameOver toNewPoint:[self propToRect:CGRectMake(1, 0, 0, 0)].origin goingTo:menuController animationFinished:^{
//        NSLog(@"transitioned from game over to menu");
//    }];
    
    [self animateFromViewController:gameOver toPoint:[self propToRect:CGRectMake(1, 0, 0, 0)].origin toViewController:menuController toPoint:[self propToRect:CGRectMake(0, 0, 0, 0)].origin animationFinished:^{
        NSLog(@"transitioned from game over to menu %@", NSStringFromCGRect(gameController.view.frame));
        [gameController stopGameLoop];
    }];
}

-(void)animateFromViewController:(UIViewController*)vc toPoint:(CGPoint)point toViewController:(UIViewController*)otherVc toPoint:(CGPoint)otherPoint animationFinished:(void (^)(void)) completion{

    [UIView animateWithDuration:0.25 animations:^{
        otherVc.view.frame = CGRectMake(otherPoint.x, otherPoint.y, otherVc.view.frame.size.width, otherVc.view.frame.size.height);
        vc.view.frame = CGRectMake(point.x, point.y, vc.view.frame.size.width, vc.view.frame.size.height);
    } completion:^(BOOL finished){
        [otherVc didMoveToParentViewController:self];
        completion();
    }];
}

//- (void)animateViewController: (UIViewController*) vc
//                toNewPoint: (CGPoint) newPoint goingTo:(UIViewController*)newVC animationFinished:(void (^)(void)) completion{
//    // Queue up the transition animation.
//    [self transitionFromViewController: vc toViewController: newVC
//                              duration: 5 options:0
//                            animations:^{
//                                // Animate the views to their final positions.
//                                newVC.view.frame = vc.view.frame;
//                                vc.view.frame = CGRectMake(newPoint.x, newPoint.y, vc.view.frame.size.width, vc.view.frame.size.height);
//                            }
//                            completion:^(BOOL finished) {
//                                // notification to the new view controller.
//                                [newVC didMoveToParentViewController:self];
//                                completion();
//                            }];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) propX:(CGFloat) x {
    return x*self.view.frame.size.width;
}

- (CGRect) propToRect: (CGRect)prop {
    CGRect viewSize = self.view.frame;
    CGRect real = CGRectMake(prop.origin.x*viewSize.size.width, prop.origin.y*viewSize.size.height, prop.size.width*viewSize.size.width, prop.size.height*viewSize.size.height);
    return real;
}

@end
