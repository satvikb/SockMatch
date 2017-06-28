//
//  Functions.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ARC4RANDOM_MAX 0x100000000

@interface Functions : NSObject {}

extern const CGFloat SmallSockPropSize;
extern const CGFloat MediumSockPropSize;
extern const CGFloat LargeSockPropSize;

typedef enum SockSize {
    Small = 0,
    Medium = 1,
    Large = 2
} SockSize;

+ (int)randomNumberBetween:(int)min maxNumber:(int)max;
+ (CGFloat) randFromMin:(CGFloat)min toMax:(CGFloat)max;
+ (CGFloat) propSizeFromSockSize:(SockSize) size;

@end
