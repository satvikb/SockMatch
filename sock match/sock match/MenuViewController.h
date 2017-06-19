//
//  MenuViewController.h
//  transal
//
//  Created by Satvik Borra on 6/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuTransition;

@interface MenuViewController : UIViewController
@property (nonatomic, weak) id<MenuTransition> delegate;
@end

@protocol MenuTransition <NSObject>
-(void)switchFromMenuToGame:(MenuViewController*) menu;
@end
