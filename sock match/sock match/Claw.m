//
//  Claw.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Claw.h"

@implementation Claw {
    CGFloat totalWidth;
    CGFloat totalHeight;
    CGPoint superOrigin;
    CGSize craneSize;
    CGSize middleSize;
    Sock* sock;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id) initClawWithSock:(Sock*)sockPackage {
    sock = sockPackage;
    
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    
    CGFloat distToLeft = sockPackage.frame.origin.x+sockPackage.frame.size.width/2;
    CGFloat distToRight = screenSize.width - distToLeft;
    
    bool craneFacesRight = distToLeft < distToRight;
    
    
    craneSize = CGSizeMake(sockPackage.frame.size.width*1.2, sockPackage.frame.size.height*1.4);
    CGSize topSize = CGSizeMake(craneSize.width, sockPackage.frame.size.height*0.2);
    CGSize bottomSize = CGSizeMake(craneSize.width, sockPackage.frame.size.height*0.2);
    middleSize = CGSizeMake(sockPackage.frame.size.width*0.2, craneSize.height-topSize.height-bottomSize.height);
    
    CGSize bodySize = CGSizeMake(MIN(distToLeft, distToRight)-sockPackage.frame.size.width/2-middleSize.width, craneSize.height/2);
    
    totalWidth = craneSize.width+bodySize.width;
    totalHeight = MAX(craneSize.height, bodySize.height);
    
    UIView* top;
    UIView* middle;
    UIView* bottom;
    
    if(craneFacesRight){
        
        crane = [[UIView alloc] initWithFrame:CGRectMake(bodySize.width, 0, craneSize.width, craneSize.height)];
        
        top = [[UIView alloc] initWithFrame:CGRectMake(0, bottomSize.height+middleSize.height, topSize.width, topSize.height)];
        top.layer.borderColor = UIColor.cyanColor.CGColor;
        top.layer.borderWidth = 2;
        
        middle = [[UIView alloc] initWithFrame:CGRectMake(0, bottomSize.height, middleSize.width, middleSize.height)];
        middle.layer.borderColor = UIColor.purpleColor.CGColor;
        middle.layer.borderWidth = 2;
        
        bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomSize.width, bottomSize.height)];
        bottom.layer.borderColor = UIColor.orangeColor.CGColor;
        bottom.layer.borderWidth = 2;
        
        body = [[UIView alloc] initWithFrame:CGRectMake(0, totalHeight*0.25, bodySize.width, bodySize.height)];
        body.layer.borderColor = UIColor.magentaColor.CGColor;
        body.layer.borderWidth = 2;
        
        superOrigin = CGPointMake(-totalWidth, sockPackage.frame.origin.y);
    }else{
        crane = [[UIView alloc] initWithFrame:CGRectMake(0, 0, craneSize.width, craneSize.height)];
        
        top = [[UIView alloc] initWithFrame:CGRectMake(0, bottomSize.height+middleSize.height, topSize.width, topSize.height)];
        top.layer.borderColor = UIColor.cyanColor.CGColor;
        top.layer.borderWidth = 2;
        
        middle = [[UIView alloc] initWithFrame:CGRectMake(craneSize.width-middleSize.width, bottomSize.height, middleSize.width, middleSize.height)];
        middle.layer.borderColor = UIColor.purpleColor.CGColor;
        middle.layer.borderWidth = 2;
        
        bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bottomSize.width, bottomSize.height)];
        bottom.layer.borderColor = UIColor.orangeColor.CGColor;
        bottom.layer.borderWidth = 2;
        
        body = [[UIView alloc] initWithFrame:CGRectMake(craneSize.width, totalHeight*0.25, bodySize.width, bodySize.height)];
        body.layer.borderColor = UIColor.magentaColor.CGColor;
        body.layer.borderWidth = 2;
        
        superOrigin = CGPointMake(screenSize.width, sockPackage.frame.origin.y);
    }
    
    self = [super initWithFrame:CGRectMake(superOrigin.x, superOrigin.y, totalWidth, totalHeight)];
    [self addSubview:crane];
    [self addSubview:body];
    
    [crane addSubview:top];
    [crane addSubview:middle];
    [crane addSubview:bottom];
    
    return self;
}

//TODO completion handler
-(void) animate {
    // TODO do for each side
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = CGRectMake(sock.frame.origin.x-totalWidth+craneSize.width-middleSize.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        NSLog(@"animate");
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect newRect = CGRectMake(-totalWidth, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
//            CGRect sockOffset = CGRectMake(sock.frame.origin.x-newRect.origin.x, sock.frame.origin.y-newRect.origin.y, sock.frame.size.width-newRect.size.width, sock.frame.size.height-newRect.size.height);
            self.frame = newRect;
            sock.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
            sock.frame = CGRectMake(newRect.origin.x, newRect.origin.y, sock.frame.size.width, sock.frame.size.height);//CGRectMake(newRect.origin.x+sockOffset.origin.x, newRect.origin.y+sockOffset.origin.y, newRect.size.width+sockOffset.size.width, newRect.size.height+sockOffset.size.height);
        } completion:^(BOOL finished){
            NSLog(@"removed sock, point");
        }];
    }];
}

@end
