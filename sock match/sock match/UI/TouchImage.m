//
//  TouchImage.m
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "TouchImage.h"

@implementation TouchImage
@synthesize block;

-(id)initWithFrame:(CGRect)frame image:(UIImage*)img{
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = true;
    self.layer.magnificationFilter = kCAFilterNearest;
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self setImage:img];
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(block != nil){
        block();
    }
}

@end
