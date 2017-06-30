//
//  DummySock.m
//  sock match
//
//  Created by Satvik Borra on 6/30/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "DummySock.h"

@implementation DummySock



-(id) initWithPos:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage *)image onBelt:(bool)startOnBelt extraPropTouchSpace:(CGFloat)extraSpace{
    self = [super initWithFrame:pos width:width sockSize:size sockId:sId image:image onBelt:startOnBelt extraPropTouchSpace:extraSpace];
    self.allowMovement = false;
    self.validSock = false;
    
    return self;
}
@end
