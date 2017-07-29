//
//  Countdown.m
//  sock match
//
//  Created by Satvik Borra on 7/3/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import "Countdown.h"
#import <objc/runtime.h>

@implementation Countdown{
    NSMutableArray<UIImage*>* numberImages;
    
    UIImageView* currentNumberImage;
}

@synthesize animationCompleteBlock;
@synthesize digitCompleteBlock;

-(id)initWithFrame:(CGRect)frame numberImages:(NSMutableArray<UIImage*>*)numImgs{
    self = [super initWithFrame:frame];
    numberImages = numImgs;

    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.35];
    
    UIImage* firstNumber = [numberImages objectAtIndex:0];
    CGFloat height = frame.size.height*0.75;
    CGFloat aspect = height / firstNumber.size.height;
    CGFloat imageWidth = firstNumber.size.width*aspect;
    
    
    currentNumberImage = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2)-(imageWidth/2), (frame.size.height-height)/2, imageWidth, height)];
    currentNumberImage.layer.magnificationFilter = kCAFilterNearest;
    currentNumberImage.contentMode = UIViewContentModeScaleAspectFit;
    currentNumberImage.animationImages = numberImages;
    currentNumberImage.animationDuration = 3;
    currentNumberImage.animationRepeatCount = 1;
    [currentNumberImage startAnimatingWithCompletionBlock:^(BOOL success){
        animationCompleteBlock(success);
    } KeyBlock: ^void{
        digitCompleteBlock();
    }];
//
    [self addSubview:currentNumberImage];
    
    
    self.layer.zPosition = 200;
    return self;
}

-(void)animateOut {
    [UIView animateWithDuration:0.5 animations:^void{
        self.transform = CGAffineTransformMakeScale(1, 0);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
    
}

@end

#define BLOCK_KEY @"BLOCK_KEY"
#define KEY_BLOCK @"KEY_BLOCK"

#define CONTENTS  @"contents"
typedef void (^Block)(BOOL success);
typedef void (^KeyBlock)(void);
@implementation UIImageView (AnimationCompletion)
    
-(void)setblock:(Block)block
{
    objc_setAssociatedObject(self, (__bridge const void *)(BLOCK_KEY), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(Block)block
{
    return objc_getAssociatedObject(self, (__bridge const void *)(BLOCK_KEY));
}

-(void)setkeyblock:(KeyBlock)block{
    objc_setAssociatedObject(self, (__bridge const void *)(KEY_BLOCK), block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(KeyBlock)keyblock
{
    return objc_getAssociatedObject(self, (__bridge const void *)(KEY_BLOCK));
}


-(void)startAnimatingWithCompletionBlock:(Block)block KeyBlock:(KeyBlock)keyBlock{
    [self startAnimatingWithCGImages:getCGImagesArray(self.animationImages) CompletionBlock:block KeyBlock:keyBlock];
}

-(void)startAnimatingWithCGImages:(NSArray*)cgImages CompletionBlock:(Block)block KeyBlock:(KeyBlock)keyBlock{
    [self setblock:block];
    [self setkeyblock:keyBlock];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    [anim setKeyPath:CONTENTS];
    [anim setValues:cgImages];
    [anim setRepeatCount:self.animationRepeatCount];
    [anim setDuration:self.animationDuration];
    anim.calculationMode = kCAAnimationDiscrete;
    
    NSMutableArray<NSNumber*>* keyTimes = [[NSMutableArray alloc] init];
    CGFloat currentTime = 0.0;
    for(int i = 0; i < cgImages.count; i++){
        [keyTimes addObject:[NSNumber numberWithFloat:currentTime]];
        
        NSTimeInterval delay = currentTime;//*self.animationDuration;
        [self performSelector:@selector(doKeyCompleteBlock) withObject: nil afterDelay:delay];
        
        currentTime += (CGFloat)cgImages.count / self.animationDuration;
        
    }
    
    anim.delegate = self;
    
    //TODO do digit complete block
    
    CALayer *ImageLayer = self.layer;
    [ImageLayer addAnimation:anim forKey:nil];
}

-(void)doKeyCompleteBlock{
    KeyBlock block_ = [self keyblock];
    if (block_)block_();
    
}

NSArray* getCGImagesArray(NSArray* UIImagesArray){
    NSMutableArray* cgImages;
    @autoreleasepool {
        cgImages = [[NSMutableArray alloc] init];
        for (UIImage* image in UIImagesArray)
            [cgImages addObject:(id)image.CGImage];
    }
    return cgImages;
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    Block block_ = [self block];
    if (block_)block_(flag);
}

@end
