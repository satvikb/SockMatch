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


-(id) initClawWithSock:(Sock*)sockPackage;
-(void) animate;
@end
