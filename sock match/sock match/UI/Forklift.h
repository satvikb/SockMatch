//
//  Forklift.h
//  sock match
//
//  Created by Satvik Borra on 6/28/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"
#import "Sounds.h"

@interface Forklift : UIImageView

typedef void (^ForkliftAnimationComplete)(void);

typedef enum ForkliftState {
    None = 0,
    GoingToSock = 1,
    PickingUpSock = 2,
    GoingBack = 3,
    Finished = 4
} ForkliftState;

-(id)initWithSock:(Sock*)s forkliftAnimationFrames:(NSMutableArray<UIImage*>*)forkliftAnimation wheelAnimationFrames:(NSMutableArray<UIImage*>*)wheelAnimation;
-(id)initDummyFromLeft:(bool)fromLeft boxImage:(UIImage*)boxImage sockImage:(UIImage*)sockImage sockSize:(CGSize)sockSize atY:(CGFloat)y forkliftAnimationFrames:(NSMutableArray<UIImage*>*)forkliftAnimation wheelAnimationFrames:(NSMutableArray<UIImage*>*)wheelAnimation;
-(void) animateAnimation;
-(void) animateWheels;
-(void) animateWheelsBackward;
-(void) animateWithSpeed:(NSTimeInterval)animateSpeed withCompletion: (void (^)(void)) completion;
-(void)dummyAnimateWithSpeed:(NSTimeInterval)speed xTranslate:(CGFloat)xTranslate withCompletion: (void (^)(void)) completion;

@property (nonatomic, assign) ForkliftState currentState;
@property (nonatomic, assign) bool forkliftFacesRight;
@property (nonatomic, copy) ForkliftAnimationComplete extraAnimationCompleteBlock;

@end
