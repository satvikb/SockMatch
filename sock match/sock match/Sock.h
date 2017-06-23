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
    CGPoint touchPoint;
}

typedef void (^SockTouchBegan)(Sock* s, CGPoint p);
typedef void (^SockTouchMoved)(Sock* s, CGPoint p, CGPoint oldPos);
typedef void (^SockTouchEnded)(Sock* s, CGPoint p);


-(id) initWithFrame:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage*) image onBelt:(bool)startOnBelt;

@property (nonatomic, assign) bool inAPair;
@property (nonatomic, assign) bool mainSockInPair;
@property (nonatomic, retain) Sock* otherSockInPair;

@property (nonatomic, assign) int sockId;
@property (nonatomic, assign) SockSize sockSize;
@property (nonatomic, assign) bool onConvayorBelt;

@property (nonatomic, assign) CGRect theoreticalFrame;

@property (nonatomic, strong) UIImageView* overlayImageView;
@property (nonatomic, strong) UIImageView* veryTopImageView;

@property (nonatomic, assign) bool allowMovement;

@property (nonatomic, assign) bool validSock; // to make sure that sock is from the current game (if the claw animates slow and a new game is started, a point is awarded)

@property (nonatomic, copy) SockTouchBegan touchBeganBlock;
@property (nonatomic, copy) SockTouchMoved touchMovedBlock;
@property (nonatomic, copy) SockTouchEnded touchEndedBlock;

@end
