//
//  Button.h
//  sock match
//
//  Created by Satvik Borra on 7/1/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ButtonPressDown)(void);

@interface Button : UIImageView{
    ButtonPressDown block;
}

@property (nonatomic, copy) ButtonPressDown block;
@property (nonatomic, copy) UIImage* normalImage;
@property (nonatomic, copy) UIImage* pressedDownImage;
@property (nonatomic, assign) bool pressedDown;
-(void) setPushedDown;
-(void) setPushedUp;

-(id)initBoxButtonWithFrame:(CGRect)frame withNormalImage:(UIImage *)normalImg pressedDownImage:(UIImage*)pressedDownImg withBlock:(ButtonPressDown)btnPressDown;
    
@end
