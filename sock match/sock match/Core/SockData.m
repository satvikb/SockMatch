//
//  SockData.m
//  sock match
//
//  Created by Satvik Borra on 7/2/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "SockData.h"

@implementation SockData

-(id)initWithOrigin:(CGPoint)origin id:(int)sockid size:(SockSize)size onConveyorBelt:(bool)onbelt{
    self = [super init];
    _origin = origin;
    _sockId = sockid;
    _sockSize = size;
    _onConvayorBelt = onbelt;
    return self;
}

static NSString* const sockDataPosition = @"sockPosition";
static NSString* const sockDataId = @"sockId";
static NSString* const sockDataSize = @"sockSize";
static NSString* const sockDataOnBelt = @"sockOnBelt";

-(instancetype)initWithCoder:(NSCoder *)decoder{
    CGPoint theOrigin = [decoder decodeCGPointForKey:sockDataPosition];
    int theSockId = [decoder decodeIntForKey:sockDataId];
    int theSockSize = [decoder decodeIntForKey:sockDataSize];
    bool theSockOnBelt = [decoder decodeBoolForKey:sockDataOnBelt];
    
    return [self initWithOrigin:theOrigin id:theSockId size:theSockSize onConveyorBelt:theSockOnBelt];
//    self = [self init];
//    if(self){
//
//    }
//    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeCGPoint:_origin forKey:sockDataPosition];
    [encoder encodeInt:_sockId forKey:sockDataId];
    [encoder encodeInt:_sockSize forKey:sockDataSize];
    [encoder encodeBool:_onConvayorBelt forKey:sockDataOnBelt];
}

@end
