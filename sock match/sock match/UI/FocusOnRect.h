//
//  FocusOnRect.h
//  sock match
//
//  Created by Satvik Borra on 7/6/17.
//  Copyright © 2017 sborra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FocusOnRect : UIView

typedef void (^TouchFocusOnRect)(void);

-(id)initWithRectToFocusOn:(CGRect)rect withLabels:(NSArray<UILabel*>*)labels screenSize:(CGSize)screen;
-(void)show:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion;
-(void)hide:(CGFloat)opacity withDuration:(NSTimeInterval)duration withCompletion:(void (^)(BOOL completed))completion;
-(bool)showNextLabel;

@property (nonatomic, copy) TouchFocusOnRect touchBlock;

@end
