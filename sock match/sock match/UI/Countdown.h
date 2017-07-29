//
//  Countdown.h
//  sock match
//
//  Created by Satvik Borra on 7/3/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DigitComplete)(void);
typedef void (^AnimationComplete)(BOOL success);

//@class AnimationCompletion;
@interface Countdown : UIView

-(id)initWithFrame:(CGRect)frame numberImages:(NSMutableArray<UIImage*>*)numImgs;
-(void)animateOut;

@property (nonatomic, copy) AnimationComplete animationCompleteBlock;
@property (nonatomic, copy) DigitComplete digitCompleteBlock;
@end

typedef void (^Block)(BOOL success);
typedef void (^KeyBlock)(void);
@interface UIImageView (AnimationCompletion) <CAAnimationDelegate>
-(void)startAnimatingWithCompletionBlock:(Block)block KeyBlock:(KeyBlock)keyBlock;

@end
