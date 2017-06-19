//
//  Sock.h
//  sock match
//
//  Created by Satvik Borra on 6/13/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Functions.h"

@interface Sock : UIImageView {
    NSString* imageName;
    CGPoint touchPoint;
}

typedef void (^SockTouchBegan)(Sock* s, CGPoint p);
typedef void (^SockTouchMoved)(Sock* s, CGPoint p);
typedef void (^SockTouchEnded)(Sock* s, CGPoint p);


-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId imageName:(NSString*) imgName onBelt:(bool)startOnBelt;

@property (nonatomic, assign) bool inAPair;
@property (nonatomic, assign) bool mainSockInPair;
@property (nonatomic, retain) Sock* otherSockInPair;

@property (nonatomic, assign) int sockId;
@property (nonatomic, assign) SockSize sockSize;
@property (nonatomic, assign) bool onConvayorBelt;

@property (nonatomic, copy) SockTouchBegan touchBeganBlock;
@property (nonatomic, copy) SockTouchMoved touchMovedBlock;
@property (nonatomic, copy) SockTouchEnded touchEndedBlock;

@end
