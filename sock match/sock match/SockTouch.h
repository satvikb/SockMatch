//
//  SockTouch.h
//  sock match
//
//  Created by Satvik Borra on 6/28/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Sock;

@interface SockTouch : UIView

typedef void (^SockTouchBegan)(NSSet<UITouch *>* touches, UIEvent* event);
typedef void (^SockTouchMoved)(NSSet<UITouch *>* touches, UIEvent* event);
typedef void (^SockTouchEnded)(NSSet<UITouch *>* touches, UIEvent* event);

@property (nonatomic, copy) SockTouchBegan touchBeganBlock;
@property (nonatomic, copy) SockTouchMoved touchMovedBlock;
@property (nonatomic, copy) SockTouchEnded touchEndedBlock;

-(id)initWithSock:(Sock*)s extraPropSpace:(CGFloat)extraSpace;
@end
