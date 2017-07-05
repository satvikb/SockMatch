//
//  Countdown.h
//  sock match
//
//  Created by Satvik Borra on 7/3/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AnimationComplete)(BOOL success);

//@class AnimationCompletion;
@interface Countdown : UIView

-(id)initWithFrame:(CGRect)frame numberImages:(NSMutableArray<UIImage*>*)numImgs detailAnimationImages:(NSMutableArray<UIImage*>*)detailImgs;
-(void)animateOut;

@property (nonatomic, copy) AnimationComplete animationCompleteBlock;
@end

typedef void (^Block)(BOOL success);
@interface UIImageView (AnimationCompletion) <CAAnimationDelegate>
-(void)startAnimatingWithCompletionBlock:(Block)block;

@end
