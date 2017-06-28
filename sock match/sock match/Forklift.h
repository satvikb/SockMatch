//
//  Forklift.h
//  sock match
//
//  Created by Satvik Borra on 6/28/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"

@interface Forklift : UIImageView


-(id)initWithSock:(Sock*)s forkliftAnimationFrames:(NSMutableArray<UIImage*>*)forkliftAnimation emissionAnimationFrames:(NSMutableArray<UIImage*>*)emissionAnimation wheelAnimationFrames:(NSMutableArray<UIImage*>*)wheelAnimation;
-(void) animateAnimation;
-(void) animateWheels;
-(void) animateWithSpeed:(NSTimeInterval)animateSpeed withCompletion: (void (^)(void)) completion;
@end
