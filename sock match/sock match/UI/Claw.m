//
//  Claw.m
//  sock match
//
//  Created by Satvik Borra on 6/19/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Claw.h"

@implementation Claw {
    bool craneFacesRight;
    
    NSMutableArray<UIImage*>* animationFrames;
    NSInteger currentFrame;
    
    CGSize screenSize;
    CGFloat totalWidth;
    CGFloat totalHeight;
    CGPoint superOrigin;
    CGSize craneSize;
    CGSize bodySize;
    CGSize topSize;
    CGSize middleSize;
    Sock* sock;
}

@synthesize currentlyAnimating;

-(id) initClawWithSock:(Sock*)sockPackage animationFrames:(NSMutableArray<UIImage*>*)animFrames middleImage:(UIImage*)middleImage topImage:(UIImage*)topImage bottomImage:(UIImage*)bottomImage{
    sock = sockPackage;
    animationFrames = animFrames;
    screenSize = UIScreen.mainScreen.bounds.size;
        
    CGFloat distToLeft = sockPackage.frame.origin.x+sockPackage.theoreticalFrame.size.width/2;
    CGFloat distToRight = screenSize.width - distToLeft;
    
    craneFacesRight = distToLeft < distToRight;
    
    
    craneSize = CGSizeMake(sockPackage.theoreticalFrame.size.width*1.2, sockPackage.theoreticalFrame.size.height*1.4);
    topSize = CGSizeMake(craneSize.width, sockPackage.theoreticalFrame.size.height*0.2);
    CGSize bottomSize = CGSizeMake(craneSize.width, sockPackage.theoreticalFrame.size.height*0.2);
    middleSize = CGSizeMake(sockPackage.theoreticalFrame.size.width*0.2, craneSize.height-topSize.height-bottomSize.height);
    
    bodySize = CGSizeMake(MIN(distToLeft, distToRight)-sockPackage.theoreticalFrame.size.width/2-middleSize.width, craneSize.height/2);
    
    totalWidth = craneSize.width+bodySize.width;
    totalHeight = MAX(craneSize.height, bodySize.height);
    
    UIImageView* top;
    UIImageView* middle;
    UIImageView* bottom;
    
    if(craneFacesRight){
        crane = [[UIView alloc] initWithFrame:CGRectMake(bodySize.width, 0, craneSize.width, craneSize.height)];
        top = [[UIImageView alloc] initWithFrame:CGRectMake(0, bottomSize.height+middleSize.height, topSize.width, topSize.height)];
        middle = [[UIImageView alloc] initWithFrame:CGRectMake(0, bottomSize.height, middleSize.width, middleSize.height)];
        bottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bottomSize.width, bottomSize.height)];
        body = [[UIView alloc] initWithFrame:CGRectMake(0, totalHeight*0.25, bodySize.width, bodySize.height)];
        superOrigin = CGPointMake(-totalWidth, sockPackage.frame.origin.y-bottomSize.height);
    }else{
        crane = [[UIView alloc] initWithFrame:CGRectMake(0, 0, craneSize.width, craneSize.height)];
        top = [[UIImageView alloc] initWithFrame:CGRectMake(0, bottomSize.height+middleSize.height, topSize.width, topSize.height)];
        middle = [[UIImageView alloc] initWithFrame:CGRectMake(craneSize.width-middleSize.width, bottomSize.height, middleSize.width, middleSize.height)];
        bottom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bottomSize.width, bottomSize.height)];
        body = [[UIView alloc] initWithFrame:CGRectMake(craneSize.width, totalHeight*0.25, bodySize.width, bodySize.height)];
        superOrigin = CGPointMake(screenSize.width, sockPackage.frame.origin.y-bottomSize.height);
    }
//    NSLog(@"height %f", totalHeight);
    self = [super initWithFrame:CGRectMake(superOrigin.x, superOrigin.y, totalWidth, totalHeight)];
//    self.layer.borderWidth = 1;
//    self.layer.borderColor = UIColor.redColor.CGColor;
    
//    UIColor* middleBg = [UIColor colorWithPatternImage: [self resizeImage:middleImage newSize:middle.frame.size]];
//    middle.backgroundColor = middleBg;
//    middle.layer.borderWidth = 2;
    
//    UIColor* topBottom = [UIColor colorWithPatternImage: [self resizeImage:topBottomImage newSize:top.frame.size]];
//    top.backgroundColor = topBottom;
//    bottom.backgroundColor = topBottom;
    
    top.contentMode = UIViewContentModeScaleAspectFit;
    top.layer.magnificationFilter = kCAFilterNearest;
    bottom.contentMode = UIViewContentModeScaleAspectFit;
    bottom.layer.magnificationFilter = kCAFilterNearest;
    middle.contentMode = UIViewContentModeScaleAspectFit;
    middle.layer.magnificationFilter = kCAFilterNearest;
    
    [top setImage:[self resizeImage:bottomImage newSize:bottom.frame.size]];
    [bottom setImage:[self resizeImage:topImage newSize:top.frame.size]];
    [middle setImage:[self resizeImage:middleImage newSize:middle.frame.size]];
    
    currentFrame = 0;
    UIImage* claw = [animationFrames objectAtIndex:currentFrame];
    [self setBodyImage:claw];
    
    [self addSubview:crane];
    [self addSubview:body];
    
    [crane addSubview:top];
    [crane addSubview:middle];
    [crane addSubview:bottom];
    
    return self;
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    // TODO newSize had zero area?
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void) animateAnimation {
    NSInteger nextFrame = (currentFrame+1)%animationFrames.count;
    currentFrame = nextFrame;
    
    [self setBodyImage: [animationFrames objectAtIndex: nextFrame]];
}

-(void) setBodyImage:(UIImage*)rawImg {
    UIImage* aImgRef = [self resizeImage:rawImg newSize:CGSizeMake(rawImg.size.width*rawImg.scale*2, rawImg.size.height*rawImg.scale*2)];
    
    UIColor* bg = [UIColor colorWithPatternImage: aImgRef];
    body.backgroundColor = bg;
}

-(void) animateWithSpeed:(NSTimeInterval)animateSpeed withCompletion: (void (^)(void)) completion {
    currentlyAnimating = true;
    [UIView animateWithDuration:animateSpeed delay:0 options:UIViewAnimationOptionCurveLinear  animations:^{
        self.frame = CGRectMake(craneFacesRight == true ? sock.frame.origin.x-totalWidth+craneSize.width-middleSize.width : sock.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        [sock removeFromSuperview];
        sock.frame = CGRectMake(craneFacesRight == true ? bodySize.width+middleSize.width : 0, topSize.height, sock.frame.size.width, sock.frame.size.height);
        [self addSubview:sock];
        
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect newRect = CGRectMake(craneFacesRight == true ? -totalWidth : screenSize.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            self.frame = newRect;
        } completion:^(BOOL finished){
            currentlyAnimating = false;
            completion();
        }];
    }];
}

@end
