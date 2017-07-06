//
//  FocusOnRect.h
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FocusOnRect : UIView

-(id)initWithRectToFocusOn:(CGRect)rect screenSize:(CGSize)screen;
-(void)animateToOpacity:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion;

@end
