//
//  SockData.h
//  sock match
//
//  Created by Satvik Borra on 7/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sock.h"
@interface SockData : NSObject <NSCoding>

-(id)initWithOrigin:(CGPoint)origin id:(int)sockid size:(SockSize)size onConveyorBelt:(bool)onbelt;

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) int sockId;
@property (nonatomic, assign) SockSize sockSize;
@property (nonatomic, assign) bool onConvayorBelt;

@end
