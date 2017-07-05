//
//  Claw.h
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sock.h"

@interface Claw : UIView {
    UIView* body;
    UIView* crane;
}

@property (nonatomic, assign) bool currentlyAnimating;

-(id) initClawWithSock:(Sock*)sockPackage animationFrames:(NSMutableArray<UIImage*>*)animFrames middleImage:(UIImage*)middleImage topImage:(UIImage*)topImage bottomImage:(UIImage*)bottomImage;
-(void) animateAnimation;
-(void) animateWithSpeed:(NSTimeInterval)animateSpeed withCompletion: (void (^)(void)) completion;
@end
