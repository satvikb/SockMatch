//
//  GameAlertView.h
//  sock match
//
//  Created by Satvik Borra on 7/21/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Button.h"

@interface GameAlertView : UIView

typedef void (^GameAlertButtonPress)(void);

@property (nonatomic, copy) GameAlertButtonPress buttonPressBlock;

-(id)initWithFrame:(CGRect)frame screenFrame:(CGRect)screen title:(NSString*)title text:(NSString*)text image:(UIImage*)img;
-(void)show;
-(void)hideAndRemove;

@end
