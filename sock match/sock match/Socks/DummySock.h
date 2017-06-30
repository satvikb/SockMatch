//
//  DummySock.h
//  sock match
//
//  Created by Satvik Borra on 6/30/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Sock.h"

@interface DummySock : Sock

-(id) initWithPos:(CGPoint)pos width:(CGFloat)width sockSize:(SockSize)size sockId:(int)sId image:(UIImage *)image onBelt:(bool)startOnBelt extraPropTouchSpace:(CGFloat)extraSpace;
    
@end
