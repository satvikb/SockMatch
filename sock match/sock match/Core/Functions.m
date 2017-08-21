//
//  Functions.m
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Functions.h"
#define DEFAULT_WIDTH 375

@implementation Functions

const CGFloat SmallSockPropSize = 0.1235;
const CGFloat MediumSockPropSize = 0.15;
const CGFloat LargeSockPropSize = 0.1765;

+ (int)randomNumberBetween:(int)min maxNumber:(int)max {
    return arc4random_uniform(max - min + 1) + min;
}

+ (CGFloat) randFromMin:(CGFloat)min toMax:(CGFloat)max{
    return ((float)arc4random() / ARC4RANDOM_MAX) * (max-min) + min;
}

+ (CGFloat) propSizeFromSockSize:(SockSize) size {
    switch (size) {
        case Small:
            return SmallSockPropSize;
        case Medium:
            return MediumSockPropSize;
        case Large:
            return LargeSockPropSize;
    }
}

+(CGFloat) fontSize:(CGFloat)fontSize{
    return fontSize*(UIScreen.mainScreen.bounds.size.width/DEFAULT_WIDTH);
}
//static func fontSize(fontSize : CGFloat) -> CGFloat{
//    return fontSize*(w/defaultWidth)
//}
@end





