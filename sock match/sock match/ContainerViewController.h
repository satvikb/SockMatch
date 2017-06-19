//
//  ContainerViewController.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"
#import "GameViewController.h"
#import "GameOverViewController.h"

@interface ContainerViewController : UIViewController <MenuTransition, GameTransition, GameOverTransition>{
    
}

@property (strong, nonatomic) MenuViewController *menuController;
@property (strong, nonatomic) GameViewController *gameController;
@property (strong, nonatomic) GameOverViewController *gameOverController;

- (void) displayContentController: (UIViewController*) content;

@end

